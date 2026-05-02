require "test_helper"

class Articles::CardComponentTest < ViewComponent::TestCase
  setup do
    @article = articles(:one)
  end

  test "タイトルとリンクが描画される" do
    render_inline(Articles::CardComponent.new(article: @article))
    assert_selector "a", text: @article.title
  end

  test "著者名が描画される" do
    render_inline(Articles::CardComponent.new(article: @article))
    assert_text @article.user.name
  end

  test "dom_id が付与される" do
    render_inline(Articles::CardComponent.new(article: @article))
    assert_selector "#article_#{@article.id}"
  end

  test "StatusBadgeComponent が含まれる（draft は gray）" do
    render_inline(Articles::CardComponent.new(article: @article))
    assert_selector ".bg-gray-100"
  end
end
