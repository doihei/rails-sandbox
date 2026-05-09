require "test_helper"

class Articles::CardComponentTest < ViewComponent::TestCase
  setup do
    @article = articles(:one)
    @user = users(:one)
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

  test "current_user なしではいいねボタンが表示されない" do
    render_inline(Articles::CardComponent.new(article: @article))
    assert_no_selector "button", text: /♡|♥/
  end

  test "current_user ありではいいねボタンが表示される" do
    render_inline(Articles::CardComponent.new(article: @article, current_user: @user))
    assert_selector "button"
  end

  test "いいね済みの場合 ♥ が表示される" do
    Like.create!(user: @user, likeable: @article)
    render_inline(Articles::CardComponent.new(article: @article, current_user: @user))
    assert_text I18n.t("articles.card.liked")
  end

  test "未いいねの場合 ♡ が表示される" do
    render_inline(Articles::CardComponent.new(article: @article, current_user: @user))
    assert_text I18n.t("articles.card.like")
  end
end
