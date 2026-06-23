module Comments
  class CreateService < ApplicationService
    def initialize(body:, article:, current_user:)
      @body = ValueObjects::CommentBody.new(body)
      @article = article
      @current_user = current_user
    end

    def call
      return Result.failure(@body.errors.first) unless @body.valid?

      comment = @article.comments.build(body: @body.to_s, user: @current_user)
      comment.save!
      Result.success(comment)
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages.join(", "))
    end
  end
end
