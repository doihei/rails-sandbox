require "rails_helper"

RSpec.describe Articles::CardComponent, type: :component do
  let(:user) { create(:user, name: "テストユーザー") }
  let(:article) { create(:article, title: "テスト記事", user: user) }

  describe "基本表示" do
    before { render_inline(described_class.new(article: article)) }

    it "タイトルをリンクとして表示する" do
      expect(page).to have_link("テスト記事")
    end

    it "著者名を表示する" do
      expect(page).to have_text("テストユーザー")
    end

    it "article の DOM ID を持つ" do
      expect(page).to have_selector("#article_#{article.id}")
    end

    it "StatusBadgeComponent が組み込まれている" do
      expect(page).to have_text(I18n.t("article_status.draft"))
    end
  end

  describe "いいねボタン" do
    context "current_user が nil の場合" do
      it "いいねボタンを表示しない" do
        render_inline(described_class.new(article: article, current_user: nil))
        expect(page).not_to have_button
      end
    end

    context "current_user がある場合（未いいね）" do
      it "いいねボタンを表示する" do
        render_inline(described_class.new(article: article, current_user: user))
        expect(page).to have_button
      end

      it "未いいねラベルを表示する" do
        render_inline(described_class.new(article: article, current_user: user))
        expect(page).to have_text(I18n.t("articles.card.like"))
      end
    end

    context "current_user がいいね済みの場合" do
      before { create(:like, user: user, likeable: article) }

      it "いいね済みラベルを表示する" do
        article_with_likes = Article.includes(:likes).find(article.id)
        render_inline(described_class.new(article: article_with_likes, current_user: user))
        expect(page).to have_text(I18n.t("articles.card.liked"))
      end
    end
  end
end
