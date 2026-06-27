module Likes
  class ToggleService < ApplicationService
    ALLOWED_TYPES = %w[Article Comment].freeze

    def initialize(user:, likeable_id:, likeable_type:)
      @user          = user
      @likeable_id   = likeable_id
      @likeable_type = likeable_type
    end

    def call
      unless ALLOWED_TYPES.include?(@likeable_type)
        return Result.failure(I18n.t("likes.errors.invalid_type", type: @likeable_type))
      end

      likeable = @likeable_type.constantize.find_by(id: @likeable_id)
      return Result.failure(I18n.t("likes.errors.not_found")) unless likeable

      if @user.id == likeable.user_id
        return Result.failure(I18n.t("likes.errors.cannot_like_own_content"))
      end

      existing = likeable.likes.find_by(user: @user)

      if existing
        existing.destroy!
        Result.success({ liked: false, count: likeable.likes.count })
      else
        likeable.likes.create!(user: @user)
        Result.success({ liked: true, count: likeable.likes.count })
      end
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages.join(", "))
    end
  end
end
