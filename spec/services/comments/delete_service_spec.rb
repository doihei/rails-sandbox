require "rails_helper"

RSpec.describe Comments::DeleteService, type: :model do
  let(:owner)   { create(:user) }
  let(:other)   { create(:user) }
  let(:comment) { create(:comment, user: owner) }

  describe ".call" do
    context "コメントの投稿者が削除する場合" do
      it "成功を返す" do
        result = described_class.call(comment: comment, current_user: owner)
        expect(result.success?).to be true
      end

      it "Comment レコードが削除される" do
        comment
        expect {
          described_class.call(comment: comment, current_user: owner)
        }.to change(Comment, :count).by(-1)
      end
    end

    context "他のユーザーが削除しようとする場合" do
      it "失敗を返す" do
        result = described_class.call(comment: comment, current_user: other)
        expect(result.success?).to be false
      end

      it "errors.unauthorized のメッセージを返す" do
        result = described_class.call(comment: comment, current_user: other)
        expect(result.error).to eq(I18n.t("errors.unauthorized"))
      end

      it "Comment レコードは削除されない" do
        comment
        expect {
          described_class.call(comment: comment, current_user: other)
        }.not_to change(Comment, :count)
      end
    end
  end
end
