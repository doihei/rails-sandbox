class CommentsController < ApplicationController
  before_action :set_article

  def create
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @article, notice: t("flash.comment.created")
    else
      redirect_to @article, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @comment = @article.comments.find(params[:id])

    if @comment.user == current_user
      @comment.destroy!
      redirect_to @article, notice: t("flash.comment.deleted"), status: :see_other
    else
      redirect_to @article, alert: t("flash.comment.unauthorized"), status: :see_other
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.expect(comment: [ :body ])
  end
end
