module Articles
  class UpdateService < ApplicationService
    def initialize(article:, current_user:, params:, tag_names: nil)
      @article = article
      @current_user = current_user
      @params = params
      @tag_names = tag_names
    end

    def call
      validates_ownership!

      [
        [ :title, @params[:title] ],
        [ :body,  @params[:body] ]
      ].each do |field, text|
        next if text.nil?   # 更新しないフィールドはスキップ

        policy = ValueObjects::NgWordPolicy.new(text)
        unless policy.valid?
          key = "articles.errors.#{field}_ng_word"
          return Result.failure(I18n.t(key, words: policy.detected_words.join("、")))
        end
      end
      # Rails 8 の counter_cache は update_counters 内で lock_version も加算する。
      # attach_tags より先に楽観的ロックを検証し、タグ更新後にリロードして update! する。
      client_lock_version = @params[:lock_version]
      update_params = @params.except(:lock_version)

      ActiveRecord::Base.transaction do
        if client_lock_version && @article.lock_version != client_lock_version.to_i
          raise ActiveRecord::StaleObjectError.new(@article, "update")
        end

        attach_tags

        if update_params.any?
          @article.reload
          @article.update!(update_params)
        end
      end

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

    def attach_tags
      return if @tag_names.nil?   # nil のとき（タグ未変更）はスキップ
      tag_list = ValueObjects::TagNameList.new(@tag_names)
      tags = tag_list.names.map { |name| Tag.find_or_create_by_name!(name) }
      @article.tags = tags          # 空配列なら全タグ削除になる（意図通り）
    end
  end
end
