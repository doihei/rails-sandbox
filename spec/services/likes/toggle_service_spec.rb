require "rails_helper"

RSpec.describe Likes::ToggleService, type: :model do
  let(:user)    { create(:user) }
  let(:article) { create(:article) }
  let(:comment) { create(:comment) }

  describe ".call" do
    context "不正な likeable_type の場合" do
      it "failure を返す" do
        result = described_class.call(user: user, likeable_id: article.id, likeable_type: "User")
        expect(result).not_to be_success
      end

      it "invalid_type エラーメッセージを返す" do
        result = described_class.call(user: user, likeable_id: article.id, likeable_type: "User")
        expect(result.error).to eq(I18n.t("likes.errors.invalid_type", type: "User"))
      end
    end

    context "対象レコードが存在しない場合" do
      it "failure を返す" do
        result = described_class.call(user: user, likeable_id: 0, likeable_type: "Article")
        expect(result).not_to be_success
      end

      it "not_found エラーメッセージを返す" do
        result = described_class.call(user: user, likeable_id: 0, likeable_type: "Article")
        expect(result.error).to eq(I18n.t("likes.errors.not_found"))
      end
    end

    context "記事にまだいいねしていない場合" do
      it "liked: true を返す" do
        result = described_class.call(user: user, likeable_id: article.id, likeable_type: "Article")
        expect(result.value[:liked]).to be true
      end

      it "like レコードが増える" do
        expect { described_class.call(user: user, likeable_id: article.id, likeable_type: "Article") }
          .to change(Like, :count).by(1)
      end

      it "count が 1 になる" do
        result = described_class.call(user: user, likeable_id: article.id, likeable_type: "Article")
        expect(result.value[:count]).to eq(1)
      end
    end

    context "すでにいいね済みの場合" do
      before { create(:like, user: user, likeable: article) }

      it "liked: false を返す" do
        result = described_class.call(user: user, likeable_id: article.id, likeable_type: "Article")
        expect(result.value[:liked]).to be false
      end

      it "like レコードが減る" do
        expect { described_class.call(user: user, likeable_id: article.id, likeable_type: "Article") }
          .to change(Like, :count).by(-1)
      end
    end

    context "Comment へのいいね" do
      it "liked: true を返す" do
        result = described_class.call(user: user, likeable_id: comment.id, likeable_type: "Comment")
        expect(result.value[:liked]).to be true
      end

      it "like レコードが増える" do
        expect { described_class.call(user: user, likeable_id: comment.id, likeable_type: "Comment") }
          .to change(Like, :count).by(1)
      end
    end
  end
end
