require "rails_helper"

RSpec.describe Like, type: :model do
  let(:user) { create(:user) }
  let(:article) { create(:article) }
  let(:comment) { create(:comment) }

  describe "ポリモーフィックアソシエーション" do
    it "Article へのいいねが有効" do
      like = build(:like, user: user, likeable: article)
      expect(like).to be_valid
    end

    it "Comment へのいいねが有効" do
      like = build(:like, user: user, likeable: comment)
      expect(like).to be_valid
    end
  end

  describe "バリデーション（一意性）" do
    it "同一ユーザーが同一記事に重複していいねすると無効" do
      create(:like, user: user, likeable: article)
      duplicate = build(:like, user: user, likeable: article)
      expect(duplicate).not_to be_valid
    end

    it "別ユーザーが同一記事にいいねすると有効" do
      create(:like, user: user, likeable: article)
      other_user = create(:user)
      like = build(:like, user: other_user, likeable: article)
      expect(like).to be_valid
    end

    it "同一ユーザーが Article と Comment それぞれにいいねすると有効" do
      create(:like, user: user, likeable: article)
      like = build(:like, user: user, likeable: comment)
      expect(like).to be_valid
    end
  end

  describe "アソシエーション（dependent: :destroy）" do
    it "記事削除で like も削除される" do
      create(:like, user: user, likeable: article)
      expect { article.destroy }.to change(Like, :count).by(-1)
    end

    it "コメント削除で like も削除される" do
      create(:like, user: user, likeable: comment)
      expect { comment.destroy }.to change(Like, :count).by(-1)
    end
  end
end
