module Mutations
  class AddComment < BaseMutation
    argument :ticket_id, ID, required: true
    argument :content, String, required: true

    field :comment, Types::CommentType, null: true
    field :errors, [ String ], null: false

    # Adds a comment to a ticket
    def resolve(ticket_id:, content:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user

      ticket = Ticket.find_by(id: ticket_id)
      return { comment: nil, errors: [ "Ticket not found" ] } unless ticket

      if user.role == "customer"
        # only comment to your own ticket
        unless ticket.user_id == user.id
          return { comment: nil, errors: [ "Not authorized" ] }
        end
        # Only comment if agent already replied
        unless ticket.comments.exists?(user: User.where(role: "agent"))
          return { comment: nil, errors: [ "You can only reply after agent response" ] }
        end
      end

      comment = ticket.comments.new(content: content, user: user)

      if comment.save
        { comment: comment, errors: [] }
      else
        { comment: nil, errors: comment.errors.full_messages }
      end
    end
  end
end
