module Articles
  class UpdateService < ApplicationService
    def initialize(article:, current_user:, params:)
      @article = article
      @current_user = current_user
      @params = params
    end

    def call
      validates_ownership!

      @article.update!(@params)
      Result.success(@article)
    rescue OwnershipError => e
      Result.failure(e.message)
    rescue ActiveRecord::StaleObjectError
      Result.failure(I18n.t("errors.stale_object"))
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages.join(", "))
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
