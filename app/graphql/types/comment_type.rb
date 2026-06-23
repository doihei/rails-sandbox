module Types
  class CommentType < Types::BaseObject
    field :id,         ID,             null: false
    field :body,       String,         null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user,       Types::UserType, null: false
  end

  def user
    dataloader.with(Sources::RecordById, User).load(object.user_id)
  end
end
