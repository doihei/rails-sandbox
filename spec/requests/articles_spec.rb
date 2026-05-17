require "rails_helper"

RSpec.describe "Articles", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:article) { create(:article, user: user) }

  before { sign_in user }

  describe "GET /articles" do
    it "一覧を取得できる" do
      get articles_path
      expect(response).to be_successful
    end
  end

  describe "GET /articles/new" do
    it "新規作成フォームを取得できる" do
      get new_article_path
      expect(response).to be_successful
    end
  end

  describe "GET /articles/:id" do
    it "詳細を取得できる" do
      get article_path(article)
      expect(response).to be_successful
    end

    it "存在しない記事は 404" do
      get article_path(id: 999999999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /articles/:id/edit" do
    it "編集フォームを取得できる" do
      get edit_article_path(article)
      expect(response).to be_successful
    end
  end

  describe "POST /articles" do
    let(:valid_params) { { article: { title: "新しい記事", body: "本文テキスト" } } }

    it "記事を作成して詳細へリダイレクトする" do
      post articles_path, params: valid_params
      expect(response).to redirect_to(article_path(Article.last))
    end

    it "Article レコードが増える" do
      expect { post articles_path, params: valid_params }
        .to change(Article, :count).by(1)
    end

    it "ArticleNotificationJob がキューイングされる" do
      expect { post articles_path, params: valid_params }
        .to have_enqueued_job(ArticleNotificationJob)
    end
  end

  describe "PATCH /articles/:id" do
    let(:valid_params) { { article: { title: "更新タイトル", body: "更新本文", lock_version: article.lock_version } } }

    it "記事を更新して詳細へリダイレクトする" do
      patch article_path(article), params: valid_params
      expect(response).to redirect_to(article_path(article))
    end

    context "stale な lock_version の場合" do
      it "リダイレクトして alert が返る" do
        Article.where(id: article.id).update_all(lock_version: article.lock_version + 1)
        patch article_path(article), params: {
          article: { title: "古いバージョンでの更新", body: article.body, lock_version: article.lock_version }
        }
        expect(response).to be_redirect
        expect(flash[:alert]).to eq(I18n.t("flash.stale_object"))
      end
    end
  end

  describe "DELETE /articles/:id" do
    it "記事を削除して一覧へリダイレクトする" do
      article_to_delete = article
      expect { delete article_path(article_to_delete) }
        .to change(Article, :count).by(-1)
    end

    it "一覧へリダイレクトする" do
      delete article_path(article)
      expect(response).to redirect_to(articles_path)
    end
  end

  describe "PATCH /articles/:id/publish" do
    it "draft 記事を公開すると詳細へリダイレクト + notice" do
      patch publish_article_path(article)
      expect(response).to redirect_to(article_path(article))
      expect(flash[:notice]).to eq(I18n.t("flash.article.published"))
    end

    it "publish 後に status が published になる" do
      patch publish_article_path(article)
      expect(article.reload.status.published?).to be true
    end

    it "他人の記事を publish しようとすると alert が返る" do
      other_article = create(:article, user: other_user)
      patch publish_article_path(other_article)
      expect(response).to redirect_to(article_path(other_article))
      expect(flash[:alert]).to eq(I18n.t("articles.publish.errors.unauthorized"))
    end

    it "未ログインで publish するとログイン画面へリダイレクト" do
      sign_out user
      patch publish_article_path(article)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "published 済み記事を再 publish すると alert が返る" do
      published_article = create(:article, :published, user: user)
      patch publish_article_path(published_article)
      expect(flash[:alert]).to eq(I18n.t("articles.publish.errors.already_published"))
    end
  end

  describe "GET /articles/popular" do
    it "人気記事一覧を取得できる" do
      get popular_articles_path
      expect(response).to be_successful
    end
  end
end
