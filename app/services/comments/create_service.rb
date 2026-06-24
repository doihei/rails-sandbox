module Comments
  class CreateService < ApplicationService
    def initialize(body:, article:, current_user:)
      @body = ValueObjects::CommentBody.new(body)
      @article = article
      @current_user = current_user
    end

    def call
      # 1. CommentBody で形式チェック（空・文字数）
      return Result.failure(@body.errors.first) unless @body.valid?

      # 2. NgWordPolicy でコンテンツチェック
      ng_policy = ValueObjects::NgWordPolicy.new(@body.to_s)
      return Result.failure(ng_policy.errors.first) unless ng_policy.valid?

      comment = @article.comments.build(body: @body.to_s, user: @current_user)
      comment.save!
      Result.success(comment)
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages.join(", "))
    end
  end
end
