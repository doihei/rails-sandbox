module Mutations
  class UpdateArticle < Mutations::AuthenticatedMutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :body, String, required: false
    argument :status, String, required: false
    argument :lock_version, Integer, required: false
    argument :tag_names,   [ String ], required: false

    field :article, Types::ArticleType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, title: nil, body: nil, status: nil, lock_version: nil, tag_names: nil)
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
        current_user: current_user,
        params: params,
        tag_names: tag_names
      )

      if result.success?
        { article: result.value, errors: [] }
      else
        { article: nil, errors: [ result.error ] }
      end
    end
  end
end
