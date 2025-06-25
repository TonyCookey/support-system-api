module Types
  class TicketType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :status, String, null: false
    field :user, Types::UserType, null: false
    field :comments, [ Types::CommentType ], null: true
    field :attachment_urls, [ String ], null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    def attachment_urls
        object.attachments.map { |file| Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true) }
    end
  end
end
