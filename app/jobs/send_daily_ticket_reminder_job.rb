class SendDailyTicketReminderJob < ApplicationJob
  queue_as :default

  # This job sends a daily reminder email to agents about open tickets.
  def perform
    User.where(role: "agent").find_each do |agent|
      open_tickets = Ticket.where(status: "open")
      AgentMailer.daily_reminder(agent, open_tickets.to_a).deliver_later
      Rails.logger.info "Sent daily reminder to agent: #{agent.email} with #{open_tickets.count} open tickets."
    end
  end
end
