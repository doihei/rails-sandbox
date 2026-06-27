module Types
  class ArticleType < Types::BaseObject
    include ApolloFederation::Object
    key fields: "id"

    field :id, ID, null: false
    field :title, String, null: false
    field :body, String, null: false
    field :status, String, null: false
    field :lock_version, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # association
    field :user, Types::UserType, null: false
    field :tags, [ Types::TagType ], null: false
    field :comments, [ Types::CommentType ], null: false
    field :comments_count, Integer, null: false
    field :likes_count, Integer, null: false
    field :liked_by_me, Boolean, null: false

    def user
      dataloader.with(Sources::RecordById, User).load(object.user_id)
    end

    def tags
      dataloader.with(Sources::AssociationLoader, :tags).load(object)
    end

    def comments
      dataloader.with(Sources::AssociationLoader, :comments).load(object)
    end

    def liked_by_me
      return false unless context[:current_user]
      user_id = context[:current_user].id
      dataloader.with(Sources::AssociationLoader, :likes).load(object).then do |likes|
        likes.any? { |like| like.user_id == user_id }
      end
    end

    def self.resolve_references(references, _context)
      ids = references.map { |r| r[:id].to_i }
      articles = Article.where(id: ids).index_by(&:id)
      references.map { |r| articles[r[:id].to_i] }
    end
  end
end
