# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :tickets, [ Types::TicketType ], null: false do
      argument :status, String, required: false
      argument :limit, Integer, required: false, default_value: 10
      argument :offset, Integer, required: false, default_value: 0
    end
    def tickets(status: nil, limit: 10, offset: 0)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user
      
      scope = user.role == "agent" ? Ticket.all : user.tickets
      scope = scope.where(status: status) if status
      scope.limit(limit).offset(offset)
    end

    field :tickets_count, Integer, null: false do
      argument :status, String, required: false
    end
    def tickets_count(status: nil)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user

      scope = user.role == "agent" ? Ticket.all : user.tickets
      scope = scope.where(status: status) if status
      scope.count
    end

    field :ticket, Types::TicketType, null: true do
      argument :id, ID, required: true
    end

    def ticket(id:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user

      ticket = Ticket.find_by(id: id)
      return nil unless ticket

      if user.role == "agent" || ticket.user_id == user.id
        ticket
      else
        raise GraphQL::ExecutionError, "Access denied"
      end
    end
  end
end
