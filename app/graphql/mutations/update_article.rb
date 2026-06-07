module Mutations
  class UpdateArticle < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :body, String, required: false
    argument :status, String, required: false
    argument :lock_version, Integer, required: false

    field :article, Types::ArticleType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, title: nil, body: nil, status: nil, lock_version: nil)
      return { article: nil, errors: [ I18n.t("errors.login_required") ] } unless context[:current_user]

      article = Article.find_by(id: id)
      return { article: nil, errors: [ I18n.t("articles.errors.not_found") ] } unless article

      params = {
        title: title,
        body: body,
        status: status,
        lock_version: lock_version
      }.compact

      result = Articles::UpdateService.call(
        article: article,
        current_user: context[:current_user],
        params: params
      )

      if result.success?
        { article: result.value, errors: [] }
      else
        { article: nil, errors: [ result.error ] }
      end
    end
  end
end
