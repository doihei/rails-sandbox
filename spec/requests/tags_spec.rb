require "rails_helper"

RSpec.describe "Tags", type: :request do
  let(:user) { create(:user) }
  let(:tag) { create(:tag, name: "ruby") }

  before { sign_in user }

  describe "GET /tags" do
    it "タグ一覧を取得できる" do
      get tags_path
      expect(response).to be_successful
    end

    it "記事のないタグも表示される" do
      create(:tag, name: "unused")
      get tags_path
      expect(response).to be_successful
      expect(response.body).to include("unused")
    end
  end

  describe "GET /tags/:id" do
    it "タグ別記事一覧を取得できる" do
      get tag_path(tag)
      expect(response).to be_successful
    end

    it "該当タグの記事が表示される" do
      article = create(:article, user: user)
      article.tags << tag
      get tag_path(tag)
      expect(response.body).to include(article.title)
    end

    it "存在しないタグは 404" do
      get tag_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end

    it "未ログインはログインページへリダイレクト" do
      sign_out user
      get tag_path(tag)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
