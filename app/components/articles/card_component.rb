class Articles::CardComponent < ViewComponent::Base
  def initialize(article:)
    @article = article
  end

  def author_name
    @article.user.name.presence || @article.user.email
  end
end
