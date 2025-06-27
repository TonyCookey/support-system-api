require 'rails_helper'

RSpec.describe 'Register Mutation', type: :request do
  let(:query) do
    <<~GQL
      mutation Register($name: String!, $email: String!, $password: String!, $role: String!) {
        register(input: { name: $name, email: $email, password: $password, role: $role }) {
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

  it 'registers a new customer successfully' do
    variables = {
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      role: 'customer'
    }

    graphql_request(query, variables: variables)

    json = JSON.parse(response.body)
    data = json["data"]["register"]

    expect(response).to have_http_status(:ok)
    expect(data["user"]["email"]).to eq("test@example.com")
    expect(data["token"]).to be_present
    expect(data["errors"]).to be_empty
  end
end
