require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # 正常系：有効なデータは保存できる
  def valid_article
    Article.new(
      title: "テストタイトル",
      body: "テスト本文",
      user: users(:one)  # ← userを渡す
    )
  end

  test "タイトルと本文があれば保存できる" do
    assert valid_article.valid?
  end

  test "タイトルがなければ無効" do
    article = valid_article.tap { |a| a.title = "" }
    assert_not article.valid?
  end

  test "本文がなければ無効" do
    article = valid_article.tap { |a| a.body = "" }
    assert_not article.valid?
  end

  test "userがなければ無効" do
    article = valid_article.tap { |a| a.user = nil }
    assert_not article.valid?
  end

  test "保存時にタイトルの前後空白が除去される" do
    article = Article.create!(
      title: "  スペース付き  ",
      body: "本文",
      user: users(:one)
    )
    assert_equal "スペース付き", article.title
  end

  test "publishedスコープは公開済みの記事だけ返す" do
    results = Article.published
    assert results.all? { |a| a.status.published? }
  end

  test "userを削除すると記事も削除される" do
    user = users(:one)
    article_count = user.articles.count
    assert_difference "Article.count", -article_count do
      user.destroy
    end
  end

  test "popularスコープはコメントが3件以上の記事を返す" do
    article = articles(:one)
    # fixtures に 2 件あるので 1 件追加して 3 件にする
    Comment.create!(article: article, user: users(:two), body: "3件目のコメント")
    assert_includes Article.popular, article
  end

  test "popularスコープはコメントが3件未満の記事は返さない" do
    # articles(:two) はコメントなし
    assert_not_includes Article.popular, articles(:two)
  end

  test "tagged_withスコープは指定タグを持つ記事を返す" do
    # articles(:one) は rails タグを持つ
    assert_includes Article.tagged_with("rails"), articles(:one)
  end

  test "tagged_withスコープは指定タグを持たない記事は返さない" do
    # articles(:two) はタグなし
    assert_not_includes Article.tagged_with("rails"), articles(:two)
  end

  test "tagged_with_allスコープは全タグを持つ記事を返す" do
    # articles(:one) は rails・ruby 両方持つ
    assert_includes Article.tagged_with_all("rails", "ruby"), articles(:one)
  end

  test "tagged_with_allスコープはタグが揃っていない記事は返さない" do
    # articles(:two) はどちらのタグも持たない
    assert_not_includes Article.tagged_with_all("rails", "ruby"), articles(:two)
  end

  test "by_latest_commentスコープはコメントがある記事が先に来る" do
    results = Article.by_latest_comment.to_a
    # articles(:one) はコメントあり、articles(:two) はコメントなし（NULLS LAST）
    assert results.index(articles(:one)) < results.index(articles(:two))
  end

  test "above_average_commentsスコープは平均より多いcomments_countの記事を返す" do
    Article.where(id: articles(:one).id).update_all(comments_count: 5)
    Article.where(id: articles(:two).id).update_all(comments_count: 1)
    # AVG(5, 1) = 3.0 なので comments_count > 3 は articles(:one) のみ
    assert_includes Article.above_average_comments, articles(:one)
    assert_not_includes Article.above_average_comments, articles(:two)
  end
end
