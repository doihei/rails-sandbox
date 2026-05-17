require "rails_helper"

RSpec.describe Likes::ToggleService, type: :model do
  let(:user) { create(:user) }
  let(:article) { create(:article) }
  let(:comment) { create(:comment) }

  describe ".call" do
    context "記事にまだいいねしていない場合" do
      it "liked: true を返す" do
        result = described_class.call(user: user, likeable: article)
        expect(result.value[:liked]).to be true
      end

      it "like レコードが増える" do
        expect { described_class.call(user: user, likeable: article) }
          .to change(Like, :count).by(1)
      end

      it "count が 1 になる" do
        result = described_class.call(user: user, likeable: article)
        expect(result.value[:count]).to eq(1)
      end
    end

    context "すでにいいね済みの場合" do
      before { create(:like, user: user, likeable: article) }

      it "liked: false を返す" do
        result = described_class.call(user: user, likeable: article)
        expect(result.value[:liked]).to be false
      end

      it "like レコードが減る" do
        expect { described_class.call(user: user, likeable: article) }
          .to change(Like, :count).by(-1)
      end
    end

    context "Comment へのいいね" do
      it "liked: true を返す" do
        result = described_class.call(user: user, likeable: comment)
        expect(result.value[:liked]).to be true
      end

      it "like レコードが増える" do
        expect { described_class.call(user: user, likeable: comment) }
          .to change(Like, :count).by(1)
      end
    end
  end
end
