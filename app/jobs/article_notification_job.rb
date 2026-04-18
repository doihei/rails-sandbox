class ArticleNotificationJob < ApplicationJob
  queue_as :default

  # 失敗したら指数関数的に間隔を空けながら3回まで再試行
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # レコードが見つからなければ再試行せず破棄
  discard_on ActiveRecord::RecordNotFound

  def perform(article)
    # article は ActiveRecord オブジェクトをそのまま渡せる
    # Solid Queue が GlobalID でシリアライズ/デシリアライズしてくれる
    Rails.logger.info "通知送信: #{article.title}"
  end
end
