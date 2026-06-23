module Mutations
  class DeleteArticle < Mutations::AuthenticatedMutation
    argument :id,           ID,      required: true
    argument :lock_version, Integer, required: true

    field :success, Boolean,   null: true
    field :errors,  [ String ], null: false

    def resolve(id:, lock_version:)
      article = Article.find_by(id: id)
      return { success: false, errors: [ I18n.t("articles.errors.not_found") ] } unless article

      result = Articles::DeleteService.call(
        article: article,
        current_user: current_user,
        lock_version: lock_version
      )

      if result.success?
        { success: true, errors: [] }
      else
        { success: false, errors: [ result.error ] }
      end
    end
  end
end
