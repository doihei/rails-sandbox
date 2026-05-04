class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    @articles = @tag.articles.includes(:user, :tags, :comments).recent
  end
end
