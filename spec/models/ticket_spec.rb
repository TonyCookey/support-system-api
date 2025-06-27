require 'rails_helper'

RSpec.describe Ticket, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:comments) }
  it { should have_many_attached(:attachments) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
end
