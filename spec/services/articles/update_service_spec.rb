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

    context "タグ名を配列で渡した場合（GraphQL 経由）" do
      it "タグが付与される" do
        result = described_class.call(article: article, current_user: owner, params: {}, tag_names: [ "Ruby", "Rails" ])
        expect(result).to be_success
        expect(result.value.tags.map(&:name)).to contain_exactly("ruby", "rails")
      end
    end

    context "空配列を渡した場合" do
      it "既存タグが全削除される" do
        article.tags = [ Tag.find_or_create_by_name!("ruby") ]
        article.reload
        result = described_class.call(article: article, current_user: owner, params: {}, tag_names: [])
        expect(result).to be_success
        expect(result.value.tags).to be_empty
      end
    end

    context "tag_names を nil で渡した場合" do
      it "タグは変更されない" do
        article.tags = [ Tag.find_or_create_by_name!("ruby") ]
        article.reload
        result = described_class.call(article: article, current_user: owner, params: {}, tag_names: nil)
        expect(result).to be_success
        expect(result.value.tags.map(&:name)).to contain_exactly("ruby")
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

    context "タイトルにNGワードが含まれる" do
      it "失敗する" do
        params = { title: "NG_TEST_WORDを含むタイトル", body: "本文", lock_version: article.lock_version }
        result = described_class.call(article: article, current_user: owner, params: params)
        expect(result).to be_failure
        expect(result.error).to include("NG_TEST_WORD")
      end
    end

    context "本文にNGワードが含まれる" do
      it "失敗する" do
        params = { title: "タイトル", body: "NG_TEST_WORDを含む本文", lock_version: article.lock_version }
        result = described_class.call(article: article, current_user: owner, params: params)
        expect(result).to be_failure
        expect(result.error).to include("NG_TEST_WORD")
      end
    end
  end
end
