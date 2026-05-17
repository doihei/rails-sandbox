require "rails_helper"

RSpec.describe Articles::PublishService, type: :model do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:draft_article) { create(:article, user: owner) }

  describe ".call" do
    context "自分の draft 記事を公開する場合" do
      it "成功を返す" do
        result = described_class.call(article: draft_article, current_user: owner)
        expect(result).to be_success
      end

      it "status が published になる" do
        described_class.call(article: draft_article, current_user: owner)
        expect(draft_article.reload.status.published?).to be true
      end

      it "ArticleNotificationJob がキューイングされる" do
        expect { described_class.call(article: draft_article, current_user: owner) }
          .to have_enqueued_job(ArticleNotificationJob)
      end
    end

    context "他人の記事を公開しようとした場合" do
      it "失敗を返す" do
        result = described_class.call(article: draft_article, current_user: other_user)
        expect(result).to be_failure
      end

      it "エラーメッセージが unauthorized になる" do
        result = described_class.call(article: draft_article, current_user: other_user)
        expect(result.error).to eq(I18n.t("articles.publish.errors.unauthorized"))
      end
    end

    context "already published な記事の場合" do
      it "失敗を返す" do
        published = create(:article, :published, user: owner)
        result = described_class.call(article: published, current_user: owner)
        expect(result).to be_failure
      end

      it "エラーメッセージが already_published になる" do
        published = create(:article, :published, user: owner)
        result = described_class.call(article: published, current_user: owner)
        expect(result.error).to eq(I18n.t("articles.publish.errors.already_published"))
      end
    end

    context "archived な記事の場合" do
      it "失敗を返す" do
        archived = create(:article, status: "archived", user: owner)
        result = described_class.call(article: archived, current_user: owner)
        expect(result).to be_failure
      end

      it "エラーメッセージが archived になる" do
        archived = create(:article, status: "archived", user: owner)
        result = described_class.call(article: archived, current_user: owner)
        expect(result.error).to eq(I18n.t("articles.publish.errors.archived"))
      end
    end
  end
end
