namespace :reminder do
  desc "Send daily open ticket reminder"
  task send: :environment do
    SendDailyTicketReminderJob.perform_now
  end
end
