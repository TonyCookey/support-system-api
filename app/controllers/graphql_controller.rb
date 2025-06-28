# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery except: :execute

  def execute
    if params[:operations].present? && params[:map].present?
      handle_multipart
    else
      handle_regular
    end
  end

  private

  # Handle regular GraphQL requests
  def handle_regular
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user
    }
    result = SupportSystemApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  # Handle multipart requests with file uploads
  def handle_multipart
    operations = JSON.parse(params[:operations])
    map = JSON.parse(params[:map])

    map.each do |file_key, paths|
      file = params[file_key]
      paths.each do |path|
        segments = path.split(".")
        last = segments.pop

        container = operations
        segments.each do |segment|
          index = segment.match?(/^\d+$/) ? segment.to_i : segment
          container = container[index]
        end

        index = last.match?(/^\d+$/) ? last.to_i : last
        container[index] = file
      end
    end

    result = SupportSystemApiSchema.execute(
      operations["query"],
      variables: operations["variables"],
      context: { current_user: current_user },
      operation_name: operations["operationName"]
    )
    render json: result
  end


  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? JSON.parse(ambiguous_param) : {}
    when ActionController::Parameters
      ambiguous_param.to_unsafe_h
    when nil
      {}
    else
      ambiguous_param
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [ { message: e.message, backtrace: e.backtrace } ], data: {} }, status: 500
  end

  private

  # extract and decode the jwt token from the Authorization header and find the current user
  def current_user
    return unless request.headers["Authorization"]

    token = request.headers["Authorization"].split.last
    decoded = JsonWebToken.decode(token)
    User.find_by(id: decoded[:user_id]) if decoded
  rescue
    nil
  end
end
