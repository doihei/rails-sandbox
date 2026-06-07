require "rails_helper"

RSpec.describe "Mutation: updateArticle", type: :request do
  let(:owner)   { create(:user) }
  let(:other)   { create(:user) }
  let!(:article) { create(:article, user: owner, title: "元のタイトル") }

  def auth_headers(user)
    token = JwtService.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  let(:mutation) do
    <<~GQL
      mutation($id: ID!, $title: String, $lockVersion: Int) {
        updateArticle(input: { id: $id, title: $title, lockVersion: $lockVersion }) {
          article { id title }
          errors
        }
      }
    GQL
  end

  def post_graphql(variables, user: owner)
    post "/graphql",
      params: { query: mutation, variables: variables },
      headers: auth_headers(user),
      as: :json
    JSON.parse(response.body).dig("data", "updateArticle")
  end

  context "オーナーが正しい lock_version で更新する場合" do
    it "タイトルが更新される" do
      result = post_graphql({ id: article.id, title: "新しいタイトル", lockVersion: article.lock_version })
      expect(result["errors"]).to be_empty
      expect(result["article"]["title"]).to eq("新しいタイトル")
    end
  end

  context "別ユーザーが更新しようとする場合" do
    it "unauthorized エラーを返す" do
      result = post_graphql({ id: article.id, title: "不正更新", lockVersion: article.lock_version }, user: other)
      expect(result["article"]).to be_nil
      expect(result["errors"]).to include(I18n.t("errors.unauthorized"))
    end
  end

  context "古い lock_version で更新しようとする場合" do
    it "stale_object エラーを返す" do
      article.update!(title: "先に更新された")
      result = post_graphql({ id: article.id, title: "競合更新", lockVersion: 0 })
      expect(result["article"]).to be_nil
      expect(result["errors"]).to include(I18n.t("errors.stale_object"))
    end
  end

  context "未認証の場合" do
    it "login_required エラーを返す" do
      post "/graphql",
        params: { query: mutation, variables: { id: article.id, title: "未認証" } },
        as: :json
      result = JSON.parse(response.body).dig("data", "updateArticle")
      expect(result["errors"]).to include(I18n.t("errors.login_required"))
    end
  end

  context "存在しない記事を更新しようとする場合" do
    it "not_found エラーを返す" do
      result = post_graphql({ id: -1, title: "存在しない記事", lockVersion: 0 })
      expect(result["article"]).to be_nil
      expect(result["errors"]).to include(I18n.t("articles.errors.not_found"))
    end
  end
end
