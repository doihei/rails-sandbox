module Mutations
  class CreateArticle < Mutations::BaseMutation
    argument :title,  String, required: true
    argument :body,   String, required: true

    field :article, Types::ArticleType, null: true
    field :errors, [ String ],          null: false

    def resolve(title:, body:)
      return { article: nil, errors: [ I18n.t("errors.login_required") ] } unless context[:current_user]

      result = Articles::CreateService.call(
        user: context[:current_user],
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
