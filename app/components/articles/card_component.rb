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

  def comments_count
    # Counter Cache: articles.comments_count カラムを読むだけ（SQL 0回）
    @article.comments_count
  end
end
