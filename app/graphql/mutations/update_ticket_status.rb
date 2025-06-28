module Mutations
  class UpdateTicketStatus < BaseMutation
    argument :ticket_id, ID, required: true
    argument :status, String, required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    # Updates the status of a ticket
    def resolve(ticket_id:, status:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.role == "agent"

      ticket = Ticket.find_by(id: ticket_id)
      return { ticket: nil, errors: [ "Ticket not found" ] } unless ticket

      if %w[open in_progress closed].include?(status)
        ticket.update(status: status)
        { ticket: ticket, errors: [] }
      else
        { ticket: nil, errors: [ "Invalid status" ] }
      end
    end
  end
end
