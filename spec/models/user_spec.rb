require "rails_helper"

RSpec.describe User, type: :model do
  # let はテストケースで初めて呼ばれたときに評価される（遅延評価）
  # let! はbefore同様に即時評価される
  let(:user) { create(:user) }

  describe "バリデーション" do
    context "有効なデータの場合" do
      it "保存できる" do
        expect(user).to be_valid
      end
    end

    context "email がない場合" do
      it "無効になる" do
        user.email = ""
        expect(user).not_to be_valid
      end
    end

    context "パスワードが6文字未満の場合" do
      it "無効になる" do
        u = build(:user, password: "abc", password_confirmation: "abc")
        expect(u).not_to be_valid
      end
    end

    context "email が重複している場合" do
      it "無効になる" do
        create(:user, email: "dup@example.com")
        dup = build(:user, email: "dup@example.com")
        expect(dup).not_to be_valid
      end
    end
  end

  describe "アソシエーション" do
    it "複数の記事を持てる" do
      expect(user).to respond_to(:articles)
    end

    it "削除すると記事も削除される" do
      create(:article, user: user)
      expect { user.destroy }.to change(Article, :count).by(-1)
    end
  end

  describe "#email_vo" do
    it "ValueObjects::Email を返す" do
      expect(user.email_vo).to be_a(ValueObjects::Email)
    end

    it "ドメインを取得できる" do
      expect(user.email_vo.domain).to eq("example.com")
    end
  end

  describe ".article_count_ranking" do
    it "記事数の多い順に返す" do
      top_user = create(:user)
      3.times { create(:article, user: top_user) }
      other_user = create(:user)
      create(:article, user: other_user)

      expect(User.article_count_ranking.first).to eq(top_user)
    end

    it "記事を持たないユーザーを含まない" do
      no_article_user = create(:user)
      expect(User.article_count_ranking).not_to include(no_article_user)
    end
  end
end
