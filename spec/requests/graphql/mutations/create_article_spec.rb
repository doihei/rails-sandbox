require "rails_helper"

RSpec.describe "Mutation: createArticle", type: :request do
  let(:user) { create(:user) }

  def auth_headers(user)
    token = JwtService.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  let(:mutation) do
    <<~GQL
      mutation {
        createArticle(input: { title: "テスト記事", body: "本文" }) {
          article { id title }
          errors
        }
      }
    GQL
  end

  context "未ログインの場合" do
    it "errors を返す" do
      post "/graphql", params: { query: mutation }, as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "createArticle", "errors")).not_to be_empty
    end
  end

  context "ログイン済みの場合" do
    it "記事が作成される" do
      expect {
        post "/graphql",
          params: { query: mutation },
          headers: auth_headers(user),
          as: :json
      }.to change(Article, :count).by(1)
    end
  end
end
