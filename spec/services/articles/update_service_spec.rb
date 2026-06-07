require "rails_helper"

RSpec.describe Articles::UpdateService, type: :model do
  let(:owner) { create(:user) }
  let(:other) { create(:user) }
  let(:article) { create(:article, user: owner) }

  describe ".call" do
    context "有効なパラメータの場合" do
      it "記事を更新して成功を返す" do
        params = { title: "更新されたタイトル", body: "更新された本文", lock_version: article.lock_version }
        result = described_class.call(article: article, current_user: owner, params: params)
        expect(result).to be_success
        expect(result.value.title).to eq("更新されたタイトル")
      end
    end

    context "古い lock_version を渡した場合" do
      it "失敗を返す" do
        article.update!(title: "先に更新された")
        params = { title: "競合更新", lock_version: 0 }
        result = described_class.call(article: article, current_user: owner, params: params)
        expect(result).to be_failure
        expect(result.error).to eq(I18n.t("errors.stale_object"))
      end
    end

    context "オーナー以外が更新しようとする場合" do
      it "失敗を返す" do
        params = { title: "不正更新", lock_version: article.lock_version }
        result = described_class.call(article: article, current_user: other, params: params)
        expect(result).to be_failure
        expect(result.error).to eq(I18n.t("errors.unauthorized"))
      end
    end
  end
end
