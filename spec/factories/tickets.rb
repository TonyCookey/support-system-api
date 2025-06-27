FactoryBot.define do
  factory :ticket do
    association :user 
    title { "Test Ticket Title" }
    description { "Test description of the ticket." }
    status { "open" }
  end
end