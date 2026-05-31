module Types
  class ArticleType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :body, String, null: false
    field :status, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # association
    field :user, Types::UserType, null: false
    field :tags, [ Types::TagType ], null: false

    def user
      dataloader.with(Sources::RecordById, User).load(object.user_id)
    end

    def tags
      dataloader.with(Sources::AssociationLoader, :tags).load(object)
    end
  end
end
