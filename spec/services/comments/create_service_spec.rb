require "rails_helper"

RSpec.describe Comments::CreateService, type: :model do
  let(:user)    { create(:user) }
  let(:article) { create(:article) }

  describe ".call" do
    context "正常系" do
      it "コメントを作成する" do
        result = described_class.call(
          body: "テストコメント", article: article, current_user: user
        )
        expect(result.success?).to be true
        expect(result.value.body).to eq("テストコメント")
      end

      it "comments_count が増える" do
        expect {
          described_class.call(body: "コメント", article: article, current_user: user)
        }.to change { article.reload.comments_count }.by(1)
      end
    end

    context "本文が空" do
      it "失敗する" do
        result = described_class.call(body: "", article: article, current_user: user)
        expect(result.success?).to be false
        expect(result.error).to include("入力")
      end
    end

    context "本文が1001文字" do
      it "失敗する" do
        result = described_class.call(
          body: "a" * 1001, article: article, current_user: user
        )
        expect(result.success?).to be false
      end
    end

    context "コメントにNGワードが含まれる" do
      it "失敗する" do
        result = described_class.call(
          body:         "NG_TEST_WORDを含むコメント",
          article:      article,
          current_user: user
        )
        expect(result).to be_failure
        expect(result.error).to include("NG_TEST_WORD")
      end

      it "形式エラーより後にチェックされる（空文字はCommentBodyが先に検知）" do
        result = described_class.call(
          body:         "",
          article:      article,
          current_user: user
        )
        # NgWordPolicy ではなく CommentBody のエラーが返る
        expect(result.error).to include("入力")
      end
    end
  end
end
