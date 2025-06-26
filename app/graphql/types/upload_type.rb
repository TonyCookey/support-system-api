module Types
  class UploadType < GraphQL::Schema::Scalar
    description "A file to be uploaded by the client"

    def self.coerce_input(value, _ctx)
      value
    end
  end
end
