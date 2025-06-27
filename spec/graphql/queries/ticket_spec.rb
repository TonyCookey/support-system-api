require 'rails_helper'

RSpec.describe 'Ticket Query', type: :request do
  let(:customer) { create(:user, role: "customer") }
  let(:ticket) { create(:ticket, user: customer) }

  let(:query) do
    <<~GRAPHQL
      query GetTicket($id: ID!) {
        ticket(id: $id) {
          id
          title
          description
        }
      }
    GRAPHQL
  end

  it 'returns the ticket for the owner' do
    post '/graphql', params: { query: query, variables: { id: ticket.id } }, headers: auth_headers(customer)

    data = json['data']['ticket']
    expect(data['id']).to eq(ticket.id.to_s)
    expect(data['title']).to eq(ticket.title)
  end

  it 'blocks access to ticket not owned by customer' do
    other_customer = create(:user, role: "customer")
    post '/graphql', params: { query: query, variables: { id: ticket.id } }, headers: auth_headers(other_customer)

    data = json['data']['ticket']
    expect(data).to be_nil
  end
end
