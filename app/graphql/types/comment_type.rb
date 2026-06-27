module Types
  class CommentType < Types::BaseObject
    field :id,         ID,             null: false
    field :body,       String,         null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user,       Types::UserType, null: false
    field :likes_count, Integer, null: false
    field :liked_by_me, Boolean, null: false

    def user
      dataloader.with(Sources::RecordById, User).load(object.user_id)
    end

    def liked_by_me
      return false unless context[:current_user]
      user_id = context[:current_user].id
      dataloader.with(Sources::AssociationLoader, :likes).load(object).then do |likes|
        likes.any? { |like| like.user_id == user_id }
      end
    end
  end
end
