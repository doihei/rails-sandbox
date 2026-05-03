require "test_helper"

class TagBadgeComponentTest < ViewComponent::TestCase
  test "タグ名が描画される" do
    tag = tags(:rails)
    render_inline(TagBadgeComponent.new(tag: tag))
    assert_text "rails"
  end

  test "バッジのスタイルクラスが付与される" do
    tag = tags(:rails)
    render_inline(TagBadgeComponent.new(tag: tag))
    assert_selector ".bg-blue-50"
  end
end
