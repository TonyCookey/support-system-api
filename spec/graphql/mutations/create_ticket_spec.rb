require 'rails_helper'

RSpec.describe 'CreateTicket Mutation', type: :request do
  let(:user) { create(:user, role: "customer") }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  let(:headers) do
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }
  end

  let(:query) do
    <<~GQL
      mutation CreateTicket($title: String!, $description: String!) {
        createTicket(input: { title: $title, description: $description }) {
          ticket {
            id
            title
            description
            status
          }
          errors
        }
      }
    GQL
  end

  it 'creates a ticket successfully' do
    variables = {
      title: "Issue with login",
      description: "Unable to log in to the dashboard."
    }

    graphql_request(query, variables: variables, headers: headers)

    json = JSON.parse(response.body)
    data = json["data"]["createTicket"]

    expect(response).to have_http_status(:ok)
    expect(data["ticket"]["title"]).to eq("Issue with login")
    expect(data["ticket"]["status"]).to eq("open")
    expect(data["errors"]).to be_empty
  end

  it 'rejects ticket creation if unauthenticated' do
    graphql_request(query, variables: {
      title: "Unauthorized",
      description: "Should not work"
    }, headers: { "Content-Type" => "application/json" })

    json = JSON.parse(response.body)
    data = json["data"]["createTicket"]

    expect(data["ticket"]).to be_nil
    expect(data["errors"]).to include("Unauthorized")
  end
end
