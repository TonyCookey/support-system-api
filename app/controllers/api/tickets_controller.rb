class Api::TicketsController < ApplicationController
  before_action :set_current_user
  before_action :authenticate_user!
  before_action :ensure_agent!

  def export
    one_month_ago = 1.month.ago
    tickets = Ticket.where(status: "closed").where("updated_at >= ?", one_month_ago)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "ID", "Title", "Description", "Submitted By", "Closed At" ]

      tickets.each do |ticket|
        csv << [
          ticket.id,
          ticket.title,
          ticket.description.truncate(100),
          ticket.user.email,
          ticket.updated_at.strftime("%Y-%m-%d")
        ]
      end
    end

    send_data csv_data, filename: "closed-tickets-#{Date.today}.csv"
  end

  private

  def ensure_agent!
    head :forbidden unless current_user && current_user.role == "agent"
  rescue
    head :forbidden
  end

  def current_user
    @current_user
  end

  def set_current_user
    return unless request.headers["Authorization"]

    token = request.headers["Authorization"].split.last
    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id]) if decoded
  rescue
    nil
  end

  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end

end