require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
    sign_in users(:one)
  end

  test "記事一覧を取得できる" do
    get articles_url
    assert_response :success
  end

  test "新規作成フォームを取得できる" do
    get new_article_url
    assert_response :success
  end

  test "記事を作成できる" do
    assert_difference("Article.count") do
      assert_enqueued_with(job: ArticleNotificationJob) do
        post articles_url, params: { article: { body: @article.body, title: @article.title } }
      end
    end
    assert_redirected_to article_url(Article.last)
  end

  test "記事詳細を取得できる" do
    get article_url(@article)
    assert_response :success
  end

  test "編集フォームを取得できる" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "記事を更新できる" do
    patch article_url(@article), params: { article: { body: @article.body, title: @article.title } }
    assert_redirected_to article_url(@article)
  end

  test "記事を削除できる" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end

  test "所有者が draft 記事を publish すると記事詳細へリダイレクト" do
    patch publish_article_url(@article)
    assert_redirected_to article_url(@article)
    assert_equal "記事を公開しました", flash[:notice]
  end

  test "publish 後に status が published に変わる" do
    patch publish_article_url(@article)
    assert_equal "published", @article.reload.status
  end

  test "他人の記事を publish しようとすると alert が返る" do
    sign_out :user
    sign_in users(:two)
    patch publish_article_url(@article)
    assert_redirected_to article_url(@article)
    assert_equal "この記事を公開する権限がありません", flash[:alert]
  end

  test "未ログインで publish するとログイン画面へリダイレクト" do
    sign_out :user
    patch publish_article_url(@article)
    assert_redirected_to new_user_session_path
  end

  test "published 済みを再 publish しようとすると alert が返る" do
    @article.update!(status: "published")
    patch publish_article_url(@article)
    assert_redirected_to article_url(@article)
    assert_equal "すでに公開済みです", flash[:alert]
  end
end
