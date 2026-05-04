class Articles::CardComponent < ViewComponent::Base
  def initialize(article:)
    @article = article
  end

  def author_name
    @article.user.name.presence || @article.user.email
  end

  def tags
    @article.tags
  end

  def comment_count
    # .size は eager load 済みなら SQL を発行しない（Ruby の .length を使う）
    # eager load なしなら COUNT クエリを発行する
    # → コントローラで includes(:comments) していることが前提
    @article.comments.size
  end
end
