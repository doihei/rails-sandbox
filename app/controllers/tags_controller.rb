class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    @articles = @tag.articles.includes(:user, :tags).recent
  end

  def index
    @tags = Tag.left_joins(:articles)
              .group("tags.id")
              .select("tags.*, COUNT(articles.id) AS articles_count")
              .order("articles_count DESC, tags.name ASC")
  end
end
