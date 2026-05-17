require "rails_helper"

RSpec.describe TagBadgeComponent, type: :component do
  let(:tag) { create(:tag, name: "ruby") }

  before { render_inline(described_class.new(tag: tag)) }

  it "タグ名を表示する" do
    expect(page).to have_text("ruby")
  end

  it "bg-blue-50 クラスを持つ" do
    expect(page).to have_selector(".bg-blue-50")
  end

  it "タグへのリンクになっている" do
    expect(page).to have_selector("a[href*='/tags/']")
  end
end
