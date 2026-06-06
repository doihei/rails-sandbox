# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_article, mutation: Mutations::CreateArticle

    # 認証
    field :create_session, mutation: Mutations::CreateSession
    field :delete_session, mutation: Mutations::DeleteSession
  end
end
