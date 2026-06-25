# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.
    field :articles,
          Types::ArticleType.connection_type,
          null: false,
          description: "記事一覧(Relay Cursor Pagination)"
    def articles
      Article.all.order(created_at: :desc)
    end

    field :article,
          Types::ArticleType,
          null: true,
          description: "id で記事を1件返す" do
      argument :id, ID, required: true
    end
    def article(id:)
      Article.find_by(id: id)
    end

    field :tags,
          [ Types::TagType ],
          null: false,
          description: "全タグ一覧（articles_count 付き）"
    def tags
      Tag.with_articles
    end

    field :tagged_articles,
          Types::ArticleType.connection_type,
          null: false,
          description: "タグに紐づく記事一覧" do
      argument :tag_id, ID, required: true
    end
    def tagged_articles(tag_id:)
      tag = Tag.find_by(id: tag_id)
      return Article.none unless tag
      tag.articles.recent
    end

    field :me, Types::UserType, null: true, description: "ログイン中のユーザー"
    def me
      context[:current_user]
    end
  end
end
