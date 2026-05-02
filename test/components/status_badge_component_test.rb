require "test_helper"

class StatusBadgeComponentTest < ViewComponent::TestCase
  test "draft は「下書き」と gray クラスで描画される" do
    status = ValueObjects::ArticleStatus.new("draft")
    render_inline(StatusBadgeComponent.new(status: status))
    assert_text "下書き"
    assert_selector ".bg-gray-100"
  end

  test "published は「公開済み」と green クラスで描画される" do
    status = ValueObjects::ArticleStatus.new("published")
    render_inline(StatusBadgeComponent.new(status: status))
    assert_text "公開済み"
    assert_selector ".bg-green-100"
  end

  test "archived は「アーカイブ」と orange クラスで描画される" do
    status = ValueObjects::ArticleStatus.new("archived")
    render_inline(StatusBadgeComponent.new(status: status))
    assert_text "アーカイブ"
    assert_selector ".bg-orange-100"
  end
end
