module Likes
  class ToggleService < ApplicationService
    def initialize(user:, likeable:)
      @user = user
      @likeable = likeable
    end

    def call
      existing = @likeable.likes.find_by(user: @user)

      if existing
        existing.destroy!
        Result.success({ liked: false, count: @likeable.likes.count })
      else
        @likeable.likes.create!(user: @user)
        Result.success({ liked: true, count: @likeable.likes.count })
      end
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.erros.full_message.join(", "))
    end
  end
end
