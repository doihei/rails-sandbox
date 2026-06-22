class ArticleNotificationJob < ApplicationJob
  queue_as :default

  # 失敗したら指数関数的に間隔を空けながら3回まで再試行
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # レコードが見つからなければ再試行せず破棄
  discard_on ActiveRecord::RecordNotFound

  def perform(article)
    NotificationClient.notify(
      article_id: article.id,
      message: "#{article.user.name || article.user.email} さんが「#{article.title}」を作成しました",
      user_id: article.user_id
    )
  end
end
