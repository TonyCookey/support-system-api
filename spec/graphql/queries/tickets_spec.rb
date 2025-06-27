require 'rails_helper'

RSpec.describe 'Tickets Query', type: :request do
  let(:customer) { create(:user, role: "customer") }
  let(:agent) { create(:user, role: "agent") }
  let!(:customer_tickets) { create_list(:ticket, 2, user: customer) }
  let!(:other_tickets) { create_list(:ticket, 2) }

  let(:query) do
    <<~GRAPHQL
      query {
        tickets {
          id
          title
          status
        }
      }
    GRAPHQL
  end

  it 'returns only the customer’s tickets' do
    graphql_request(params: { query: query }, headers: auth_headers(customer))

    data = json['data']['tickets']
    expect(data.size).to eq(2)
    expect(data.pluck('id')).to match_array(customer_tickets.map { |t| t.id.to_s })
  end

  it 'returns all tickets for agent' do
    graphql_request(params: { query: query }, headers: auth_headers(agent))

    data = json['data']['tickets']
    expect(data.size).to eq(4)
  end
end
