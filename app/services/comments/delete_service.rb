module Comments
  class DeleteService < ApplicationService
    def initialize(comment:, current_user:)
      @comment = comment
      @current_user = current_user
    end

    def call
      validates_ownership!
      @comment.destroy!
      Result.success()
    rescue OwnershipError => e
      Result.failure(e.message)
    end

    private

    def validates_ownership!
      unless @comment.user_id == @current_user.id
        raise OwnershipError, I18n.t("errors.unauthorized")
      end
    end

    OwnershipError = Class.new(StandardError)
  end
end
