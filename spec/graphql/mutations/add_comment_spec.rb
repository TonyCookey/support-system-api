require 'rails_helper'

RSpec.describe 'AddComment', type: :request do
  let(:ticket_owner) { create(:user, role: 'customer') }
  let(:agent) { create(:user, role: 'agent') }
  let(:other_customer) { create(:user, role: 'customer') }
  let(:ticket) { create(:ticket, user: ticket_owner) }

  let(:mutation) do
    <<~GQL
      mutation AddComment($ticketId: ID!, $content: String!) {
        addComment(input: { ticketId: $ticketId, content: $content }) {
          comment {
            id
            content
            user {
              id
              role
            }
          }
          errors
        }
      }
    GQL
  end
  
  context 'when the ticket owner attempts to add the first comment' do
    it 'it fails to add the comment' do
      graphql_request(mutation, variables: { ticketId: ticket.id.to_s, content: 'Customer reply' }, headers: auth_headers(ticket_owner))

      json = JSON.parse(response.body)
      data = json['data']['addComment']

      expect(data['comment']).to be_nil
      expect(data['errors']).to include("You can only reply after agent response")
    end
  end

  context 'when an agent adds a comment first' do
    it 'adds the comment successfully' do
      graphql_request(mutation, variables: { ticketId: ticket.id.to_s, content: 'Agent response' }, headers: auth_headers(agent))

      json = JSON.parse(response.body)
      data = json['data']['addComment']

      expect(data['comment']['content']).to eq('Agent response')
      expect(data['errors']).to be_empty
    end
  end

   context 'when the ticket owner attempts to add the second comment' do
    it 'it adds the comment successfully' do
      create(:comment, user: agent, ticket: ticket, content: 'Agent has responded first')
      graphql_request(mutation, variables: { ticketId: ticket.id.to_s, content: 'Customer reply' }, headers: auth_headers(ticket_owner))

      json = JSON.parse(response.body)
      data = json['data']['addComment']

      expect(data['comment']['content']).to eq('Customer reply')
      expect(data['errors']).to be_empty
    end
  end

  context 'when a different customer tries to comment' do
    it 'returns an error' do
      graphql_request(mutation, variables: { ticketId: ticket.id.to_s, content: 'Invalid user' }, headers: auth_headers(other_customer))

      json = JSON.parse(response.body)
      data = json['data']['addComment']

      expect(data['comment']).to be_nil
      expect(data['errors']).to include('Not authorized')
    end
  end

  context 'when unauthenticated' do
    it 'returns an authorization error' do
      graphql_request(mutation, variables: { ticketId: ticket.id.to_s, content: 'Should fail' })

      json = JSON.parse(response.body)
      expect(json['errors'].first['message']).to eq('Unauthorized')
    end
  end
end
