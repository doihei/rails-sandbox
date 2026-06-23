module Mutations
  class AuthenticatedMutation < Mutations::BaseMutation
    def ready?(**_args)
      return [ false, { errors: [ I18n.t("errors.login_required") ] } ] unless current_user
      super
    end

    private

    def current_user
      context[:current_user]
    end
  end
end
