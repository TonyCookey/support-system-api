# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :update_ticket_status, mutation: Mutations::UpdateTicketStatus
    field :add_comment, mutation: Mutations::AddComment
    field :create_ticket, mutation: Mutations::CreateTicket
    field :login, mutation: Mutations::Login
    field :register, mutation: Mutations::Register
  end
end
