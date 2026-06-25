require "rails_helper"

RSpec.describe Articles::CreateService, type: :model do
  let(:user) { create(:user) }
  let(:valid_params) { { title: "新しい記事", body: "本文テキスト" } }

  describe ".call" do
    context "有効なパラメータの場合" do
      it "記事を作成して成功を返す" do
        result = described_class.call(user: user, params: valid_params)
        expect(result).to be_success
      end

      it "Article レコードが増える" do
        expect { described_class.call(user: user, params: valid_params) }
          .to change(Article, :count).by(1)
      end

      it "ArticleNotificationJob がキューイングされる" do
        expect { described_class.call(user: user, params: valid_params) }
          .to have_enqueued_job(ArticleNotificationJob)
      end
    end

    context "タイトルが空の場合" do
      it "失敗を返す" do
        result = described_class.call(user: user, params: { title: "", body: "本文" })
        expect(result).to be_failure
      end
    end

    context "本文が空の場合" do
      it "失敗を返す" do
        result = described_class.call(user: user, params: { title: "タイトル", body: "" })
        expect(result).to be_failure
      end
    end

    context "タグ名を文字列で渡した場合" do
      it "タグが付与される" do
        result = described_class.call(user: user, params: valid_params, tag_names: "ruby, rails")
        expect(result.value.tags.map(&:name)).to contain_exactly("ruby", "rails")
      end
    end

    context "タグ名を配列で渡した場合（GraphQL 経由）" do
      it "タグが付与される" do
        result = described_class.call(user: user, params: valid_params, tag_names: [ "Ruby", "Rails" ])
        expect(result.value.tags.map(&:name)).to contain_exactly("ruby", "rails")
      end
    end

    context "空のタグ名を渡した場合" do
      it "エラーなく成功する" do
        result = described_class.call(user: user, params: valid_params, tag_names: "")
        expect(result).to be_success
        expect(result.value.tags).to be_empty
      end
    end

    context "空配列を渡した場合" do
      it "エラーなく成功する" do
        result = described_class.call(user: user, params: valid_params, tag_names: [])
        expect(result).to be_success
        expect(result.value.tags).to be_empty
      end
    end

    context "タイトルにNGワードが含まれる" do
      it "失敗する" do
        ng_params = { title: "NG_TEST_WORDを含むタイトル", body: "本文" }
        result = described_class.call(user: user, params: ng_params)
        expect(result).to be_failure
        expect(result.error).to include("NG_TEST_WORD")
      end
    end

    context "本文にNGワードが含まれる" do
      it "失敗する" do
        ng_params = { title: "タイトル", body: "NG_TEST_WORDを含む本文" }
        result = described_class.call(user: user, params: ng_params)
        expect(result).to be_failure
        expect(result.error).to include("NG_TEST_WORD")
      end
    end
  end
end
