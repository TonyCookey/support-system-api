class AgentMailer < ApplicationMailer
  def daily_reminder(agent, tickets)
    @agent = agent
    @tickets = tickets
    Rails.logger.info "Sending daily reminder to agent: #{@agent.email} with #{@tickets.count} open tickets."
    mail(to: @agent.email, subject: "Daily Open Tickets Reminder")
  end
end
