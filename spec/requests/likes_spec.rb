require "rails_helper"

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let(:article) { create(:article) }
  let(:comment) { create(:comment) }

  before { sign_in user }

  describe "POST /likes" do
    context "記事へのいいね" do
      it "いいねして root へリダイレクト + notice" do
        post likes_path, params: { likeable_type: "Article", likeable_id: article.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t("flash.like.created"))
      end
    end

    context "いいね済み記事のトグル" do
      before { create(:like, user: user, likeable: article) }

      it "いいねを取り消して root へリダイレクト + notice" do
        post likes_path, params: { likeable_type: "Article", likeable_id: article.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t("flash.like.destroyed"))
      end
    end

    context "コメントへのいいね" do
      it "いいねして root へリダイレクト + notice" do
        post likes_path, params: { likeable_type: "Comment", likeable_id: comment.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t("flash.like.created"))
      end
    end

    context "不正な likeable_type" do
      it "400 Bad Request を返す" do
        post likes_path, params: { likeable_type: "User", likeable_id: user.id }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "存在しない likeable_id" do
      it "404 Not Found を返す" do
        post likes_path, params: { likeable_type: "Article", likeable_id: 999999999 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "未ログイン" do
      it "ログイン画面へリダイレクトする" do
        sign_out user
        post likes_path, params: { likeable_type: "Article", likeable_id: article.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
