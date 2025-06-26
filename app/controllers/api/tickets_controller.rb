class Api::TicketsController < ApplicationController
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
    head :forbidden unless current_user&.agent?
  end
end
