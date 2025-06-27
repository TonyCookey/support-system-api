require 'rails_helper'

RSpec.describe 'UpdateTicketStatus Mutation', type: :request do
  let(:agent) { create(:user, role: "agent") }
  let(:customer) { create(:user, role: "customer") }
  let(:ticket) { create(:ticket, status: "open") }

  let(:mutation) do
    <<~GQL
      mutation UpdateTicketStatus($ticketId: ID!, $status: String!) {
        updateTicketStatus(input: { ticketId: $ticketId, status: $status }) {
          ticket {
            id
            status
          }
          errors
        }
      }
    GQL
  end

  def auth_headers(user)
    {
      "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}",
      "Content-Type" => "application/json"
    }
  end

  it 'allows an agent to update ticket status' do
    graphql_request(mutation, variables: {
      ticketId: ticket.id,
      status: "closed"
    }, headers: auth_headers(agent))

    json = JSON.parse(response.body)
    data = json["data"]["updateTicketStatus"]

    expect(response).to have_http_status(:ok)
    expect(data["ticket"]["status"]).to eq("closed")
    expect(data["errors"]).to be_empty
  end

  it 'prevents a customer from updating ticket status' do
    graphql_request(mutation, variables: {
      ticketId: ticket.id,
      status: "open"
    }, headers: auth_headers(customer)) 

    json = JSON.parse(response.body)
    data = json["data"]
    error = json["errors"][0]

    expect(data["updateTicketStatus"]).to be_nil
    expect(error["message"]).to include("Unauthorized")
  end
end
