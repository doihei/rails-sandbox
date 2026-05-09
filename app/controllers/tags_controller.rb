class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    @articles = @tag.articles.includes(:user, :tags, :likes).recent
  end

  def index
    @tags = Tag.order(articles_count: :desc, name: :asc)
  end
end
