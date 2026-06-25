module Articles
  class CreateService < ApplicationService
    def initialize(user:, params:, tag_names: nil)
      @user = user
      @params = params
      @tag_names = tag_names
    end

    def call
      # タイトルの NG ワードチェック
      title_policy = ValueObjects::NgWordPolicy.new(@params[:title])
      return Result.failure(
        I18n.t("articles.errors.title_ng_word", words: title_policy.detected_words.join(", "))
      ) unless title_policy.valid?

      # 本文の NG ワードチェック
      body_policy = ValueObjects::NgWordPolicy.new(@params[:body])
      return Result.failure(
        I18n.t("articles.errors.body_ng_word", words: body_policy.detected_words.join(", "))
      ) unless body_policy.valid?

      article = nil
      ActiveRecord::Base.transaction do
        article = @user.articles.build(@params)
        article.save!
        attach_tags(article)
      end
      ArticleNotificationJob.perform_later(article)
      Result.success(article)
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages.join(", "))
    end

    private

    def attach_tags(article)
      tag_list = ValueObjects::TagNameList.new(@tag_names)
      return if tag_list.empty?
      tags = tag_list.names.map { |name| Tag.find_or_create_by_name!(name) }
      article.tags = tags
    end
  end
end
