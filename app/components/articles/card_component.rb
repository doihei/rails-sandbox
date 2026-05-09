class Articles::CardComponent < ViewComponent::Base
  def initialize(article:, current_user: nil)
    @article = article
    @current_user = current_user
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

  def likes_count
    @article.likes.size
  end

  def liked?
    return false unless @current_user
    @article.likes.any? { |l| l.user_id == @current_user.id }
  end
end
