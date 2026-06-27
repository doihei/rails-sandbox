# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # 認証
    field :create_session, mutation: Mutations::CreateSession
    field :delete_session, mutation: Mutations::DeleteSession

    # 記事
    field :create_article, mutation: Mutations::CreateArticle
    field :update_article, mutation: Mutations::UpdateArticle
    field :delete_article, mutation: Mutations::DeleteArticle

    # コメント
    field :create_comment, mutation: Mutations::CreateComment
    field :delete_comment, mutation: Mutations::DeleteComment

    # いいね
    field :toggle_like,    mutation: Mutations::ToggleLike
  end
end
