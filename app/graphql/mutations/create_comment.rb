module Mutations
  class CreateComment < Mutations::AuthenticatedMutation
    argument :article_id, ID,     required: true
    argument :body,       String, required: true

    field :comment, Types::CommentType, null: true
    field :errors,  [ String ],         null: false

    def resolve(article_id:, body:)
      article = Article.find_by(id: article_id)
      return { comment: nil, errors: [ I18n.t("articles.errors.not_found") ] } unless article

      result = Comments::CreateService.call(
        body: body,
        article: article,
        current_user: current_user
      )

      if result.success?
        { comment: result.value, errors: [] }
      else
        { comment: nil, errors: [ result.error ] }
      end
    end
  end
end
