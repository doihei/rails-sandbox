require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # 正常系：有効なデータは保存できる
  test "タイトルと本文があれば保存できる" do
    article = Article.new(title: "テストタイトル", body: "テスト本文")
    assert article.valid?
  end

  # 異常系：タイトルなしは無効
  test "タイトルがなければ無効" do
    article = Article.new(title: "", body: "本文")
    assert_not article.valid?
    assert_includes article.errors[:title], "can't be blank"
  end

  # 異常系：本文なしは無効
  test "本文がなければ無効" do
    article = Article.new(title: "タイトル", body: "")
    assert_not article.valid?
  end

  # コールバックのテスト
  test "保存時にタイトルの前後空白が除去される" do
    article = Article.create!(title: "  スペース付き  ", body: "本文")
    assert_equal "スペース付き", article.title
  end

  # scopeのテスト
  test "publishedスコープは公開済みの記事だけ返す" do
    Article.create!(title: "公開記事", body: "本文", status: "published")
    Article.create!(title: "下書き",   body: "本文", status: "draft")

    results = Article.published
    assert results.all? { |a| a.status == "published" }
  end
end
