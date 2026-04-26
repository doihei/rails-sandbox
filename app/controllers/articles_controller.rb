class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy publish ]

  # GET /articles or /articles.json
  def index
    @articles = Article.includes(:user)
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    result = Articles::CreateService.call(
      user: current_user,
      params: article_params
    )

    respond_to do |format|
      if result.success?
        format.html { redirect_to result.value, notice: "記事を作成しました" }
        format.json { render :show, status: :created, location: result.value }
      else
        @article = current_user.articles.build(article_params)
        @article.errors.add(:base, result.error)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "記事を更新しました", status: :see_other }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "記事を削除しました", status: :see_other }
      format.json { head :no_content }
    end
  end

  # PATCH /articles/:id/publish
  def publish
    result = Articles::PublishService.call(
      article: @article,
      current_user: current_user
    )

    if result.success?
      redirect_to result.value, notice: "記事を公開しました"
    else
      redirect_to @article, alert: result.error
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params.expect(:id))
    end

    def article_params
      params.expect(article: [ :title, :body, :status ])
    end
end
