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
    assert results.all? { |a| a.status == "published" }
  end

  test "userを削除すると記事も削除される" do
    user = users(:one)
    article_count = user.articles.count
    assert_difference "Article.count", -article_count do
      user.destroy
    end
  end
end
