module Articles
  class PublishService < ApplicationService
    def initialize(article:, current_user:)
      @article = article
      @current_user = current_user
    end

    def call
      validates_ownership!
      validates_publishable!

      @article.update!(status: "published")
      ArticleNotificationJob.perform_later(@article)

      Result.success(@article)
    rescue OwnershipError => e
      Result.failure(e.message)
    rescue PublishError => e
      Result.failure(e.message)
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages.join(", "))
    end

    private

    def validates_ownership!
      unless @article.user == @current_user
        raise OwnershipError, I18n.t("articles.publish.errors.unauthorized")
      end
    end

    def validates_publishable!
      if @article.status.published?
        raise PublishError, I18n.t("articles.publish.errors.already_published")
      end
      if @article.status.archived?
        raise PublishError, I18n.t("articles.publish.errors.archived")
      end
    end

    OwnershipError = Class.new(StandardError)
    PublishError = Class.new(StandardError)
  end
end
