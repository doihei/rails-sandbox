require "rails_helper"

RSpec.describe StatusBadgeComponent, type: :component do
  def render_badge(status_value)
    status = ValueObjects::ArticleStatus.new(status_value)
    render_inline(described_class.new(status: status))
  end

  describe "draft" do
    before { render_badge("draft") }

    it "日本語テキストを表示する" do
      expect(page).to have_text(I18n.t("article_status.draft"))
    end

    it "draft 用クラスを持つ" do
      expect(page).to have_selector(".bg-gray-100")
    end
  end

  describe "published" do
    before { render_badge("published") }

    it "日本語テキストを表示する" do
      expect(page).to have_text(I18n.t("article_status.published"))
    end

    it "published 用クラスを持つ" do
      expect(page).to have_selector(".bg-green-100")
    end
  end

  describe "archived" do
    before { render_badge("archived") }

    it "日本語テキストを表示する" do
      expect(page).to have_text(I18n.t("article_status.archived"))
    end

    it "archived 用クラスを持つ" do
      expect(page).to have_selector(".bg-orange-100")
    end
  end
end
