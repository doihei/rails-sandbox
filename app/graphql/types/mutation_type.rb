# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # 記事
    field :create_article, mutation: Mutations::CreateArticle
    field :update_article, mutation: Mutations::UpdateArticle
    field :delete_article, mutation: Mutations::DeleteArticle

    # 認証
    field :create_session, mutation: Mutations::CreateSession
    field :delete_session, mutation: Mutations::DeleteSession
  end
end
