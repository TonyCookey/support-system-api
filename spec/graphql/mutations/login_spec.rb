require 'rails_helper'

RSpec.describe 'Login Mutation', type: :request do
  let(:user) { create(:user, email: "agent@example.com", password: "password", role: "agent") }

  let(:query) do
    <<~GQL
      mutation Login($email: String!, $password: String!) {
        login(input: { email: $email, password: $password }) {
          token
          user {
            id
            email
            role
          }
          errors
        }
      }
    GQL
  end

  it 'logs in a valid user' do
    user

    graphql_request(query, variables: { email: "agent@example.com", password: "password" })

    json = JSON.parse(response.body)
    data = json["data"]["login"]

    expect(response).to have_http_status(:ok)
    expect(data["token"]).to be_present
    expect(data["user"]["email"]).to eq("agent@example.com")
  end
end
