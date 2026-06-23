module Articles
  class DeleteService < ApplicationService
    def initialize(article:, current_user:, lock_version:)
      @article = article
      @current_user = current_user
      @lock_version = lock_version
    end

    def call
      validates_ownership!
      @article.lock_version = @lock_version
      @article.destroy!
      Result.success()
    rescue OwnershipError => e
      Result.failure(e.message)
    rescue ActiveRecord::StaleObjectError
      Result.failure(I18n.t("errors.stale_object"))
    end

    private

    def validates_ownership!
      unless @article.user_id == @current_user.id
        raise OwnershipError, I18n.t("errors.unauthorized")
      end
    end

    OwnershipError = Class.new(StandardError)
  end
end
