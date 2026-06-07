require "rails_helper"

RSpec.describe Articles::DeleteService, type: :model do
  let(:owner) { create(:user) }
  let(:other) { create(:user) }
  let(:article) { create(:article, user: owner) }

  describe ".call" do
    context "有効なパラメータの場合" do
      it "記事を削除して成功を返す" do
        result = described_class.call(article: article, current_user: owner, lock_version: article.lock_version)
        expect(result).to be_success
        expect(result.value).to be_nil
      end
    end

    context "古い lock_version を渡した場合" do
      it "失敗を返す" do
        article.update!(title: "先に更新された")
        result = described_class.call(article: article, current_user: owner, lock_version: 0)
        expect(result).to be_failure
        expect(result.error).to eq(I18n.t("errors.stale_object"))
      end
    end

    context "オーナー以外が削除しようとする場合" do
      it "失敗を返す" do
        result = described_class.call(article: article, current_user: other, lock_version: article.lock_version)
        expect(result).to be_failure
        expect(result.error).to eq(I18n.t("errors.unauthorized"))
      end
    end
  end
end
