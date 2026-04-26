module Articles
  class CreateService < ApplicationService
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      article = @user.articles.build(@params)

      if article.save
        ArticleNotificationJob.perform_later(article)
        Result.success(article)
      else
        Result.failure(article.errors.full_messages.join(", "))
      end
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.erros.full_messages.join(", "))
    end
  end
end
