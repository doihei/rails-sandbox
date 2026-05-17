require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:article) { create(:article) }
  let(:user) { create(:user) }

  describe "バリデーション" do
    it "body・article・user があれば有効" do
      comment = build(:comment, article: article, user: user)
      expect(comment).to be_valid
    end

    it "body が空なら無効" do
      comment = build(:comment, body: "", article: article, user: user)
      expect(comment).not_to be_valid
    end

    it "body が1001文字以上なら無効" do
      comment = build(:comment, body: "a" * 1001, article: article, user: user)
      expect(comment).not_to be_valid
    end

    it "body が1000文字なら有効" do
      comment = build(:comment, body: "a" * 1000, article: article, user: user)
      expect(comment).to be_valid
    end
  end

  describe "アソシエーション" do
    it "記事削除でコメントも削除される" do
      comment = create(:comment, article: article, user: user)
      expect { article.destroy }.to change(Comment, :count).by(-1)
    end
  end

  describe "スコープ" do
    context ".recent" do
      it "作成日時の降順で返す" do
        old_comment = create(:comment, article: article, user: user, created_at: 2.days.ago)
        new_comment = create(:comment, article: article, user: user, created_at: 1.day.ago)
        expect(Comment.recent.to_a).to eq([ new_comment, old_comment ])
      end
    end
  end

  describe "counter_cache" do
    it "コメント作成で記事の comments_count が増える" do
      expect { create(:comment, article: article, user: user) }
        .to change { article.reload.comments_count }.by(1)
    end

    it "コメント削除で記事の comments_count が減る" do
      comment = create(:comment, article: article, user: user)
      expect { comment.destroy }
        .to change { article.reload.comments_count }.by(-1)
    end
  end
end
