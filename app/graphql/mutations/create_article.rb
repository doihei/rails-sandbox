module Mutations
  class CreateArticle < Mutations::AuthenticatedMutation
    argument :title,  String, required: true
    argument :body,   String, required: true

    field :article, Types::ArticleType, null: true
    field :errors, [ String ],          null: false

    def resolve(title:, body:)
      result = Articles::CreateService.call(
        user: current_user,
        params: { title: title, body: body }
      )

      if result.success?
        { article: result.value, errors: [] }
      else
        { article: nil, errors: [ result.error ] }
      end
    end
  end
end
