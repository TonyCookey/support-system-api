module Mutations
  class CreateTicket < BaseMutation
    argument :title, String, required: true
    argument :description, String, required: true
argument :attachments, [ Types::UploadType ], required: false

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    def resolve(title:, description:, attachments: [])
      user = context[:current_user]
      return { ticket: nil, errors: [ "Unauthorized" ] } unless user && user.role == "customer"

      ticket = user.tickets.new(title: title, description: description, status: "open")
      if attachments.present?
        attachments.each { |file| ticket.attachments.attach(file) }
      end

      if ticket.save
        { ticket: ticket, errors: [] }
      else
        { ticket: nil, errors: ticket.errors.full_messages }
      end
    end
  end
end
