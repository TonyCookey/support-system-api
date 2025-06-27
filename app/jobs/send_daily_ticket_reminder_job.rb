class SendDailyTicketReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.where(role: "agent").find_each do |agent|
      open_tickets = Ticket.where(status: "open")
      AgentMailer.daily_reminder(agent, open_tickets.to_a).deliver_now
    end
  end
end
