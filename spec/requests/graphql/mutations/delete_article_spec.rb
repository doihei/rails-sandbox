require "rails_helper"

RSpec.describe "Mutation: deleteArticle", type: :request do
  let(:owner)    { create(:user) }
  let(:other)    { create(:user) }
  let!(:article) { create(:article, user: owner) }

  def auth_headers(user)
    token = JwtService.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  let(:mutation) do
    <<~GQL
      mutation($id: ID!, $lockVersion: Int!) {
        deleteArticle(input: { id: $id, lockVersion: $lockVersion }) {
          success
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
    JSON.parse(response.body).dig("data", "deleteArticle")
  end

  context "オーナーが削除する場合" do
    it "削除に成功し Article が減る" do
      article
      expect {
        post_graphql({ id: article.id, lockVersion: article.lock_version })
      }.to change(Article, :count).by(-1)

      result = JSON.parse(response.body).dig("data", "deleteArticle")
      expect(result["success"]).to be true
    end
  end

  context "別ユーザーが削除しようとする場合" do
    it "unauthorized エラーを返す" do
      result = post_graphql({ id: article.id, lockVersion: article.lock_version }, user: other)
      expect(result["success"]).to be false
      expect(result["errors"]).to include(I18n.t("errors.unauthorized"))
    end
  end

  context "古い lock_version で削除しようとする場合" do
    it "stale_object エラーを返す" do
      article.update!(title: "先に更新された")
      result = post_graphql({ id: article.id, lockVersion: 0 })
      expect(result["success"]).to be false
      expect(result["errors"]).to include(I18n.t("errors.stale_object"))
    end
  end

  context "未認証の場合" do
    it "login_required エラーを返す" do
      post "/graphql",
        params: { query: mutation, variables: { id: article.id, lockVersion: article.lock_version } },
        as: :json
      result = JSON.parse(response.body).dig("data", "deleteArticle")
      expect(result["success"]).to be false
      expect(result["errors"]).to include(I18n.t("errors.login_required"))
    end
  end

  context "存在しない記事を削除しようとする場合" do
    it "not_found エラーを返す" do
      result = post_graphql({ id: -1, lockVersion: 0 })
      expect(result["success"]).to be false
      expect(result["errors"]).to include(I18n.t("articles.errors.not_found"))
    end
  end
end
