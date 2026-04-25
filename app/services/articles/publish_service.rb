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
        raise OwnershipError, "この記事を公開する権限がありません"
      end
    end

    def validates_publishable!
      if @article.status == "published"
        raise PublishError, "すでに公開済みです"
      end
      if @article.status == "archived"
        raise PublishError, "アーカイブ済みの記事は公開できません"
      end
    end

    OwnershipError = Class.new(StandardError)
    PublishError = Class.new(StandardError)
  end
end
