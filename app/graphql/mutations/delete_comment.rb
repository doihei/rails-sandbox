module Mutations
  class DeleteComment < Mutations::AuthenticatedMutation
    argument :id, ID, required: true

    field :success, Boolean,  null: true
    field :errors,  [ String ], null: false

    def resolve(id:)
      comment = Comment.find_by(id: id)
      return { success: false, errors: [ I18n.t("comments.errors.not_found") ] } unless comment

      result = Comments::DeleteService.call(
        comment: comment,
        current_user: current_user
      )

      if result.success?
        { success: true, errors: [] }
      else
        { success: false, errors: [ result.error ] }
      end
    end
  end
end
