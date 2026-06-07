require "rails_helper"

RSpec.describe "Query: me", type: :request do
  let(:user) { create(:user) }
  let(:query) do
    <<~GQL
      query {
        me {
          id
          name
          email
        }
      }
    GQL
  end

  context "認証済みの場合" do
    it "ログイン中のユーザーを返す" do
      token = JwtService.encode(user_id: user.id)
      post "/graphql",
        params: { query: query },
        headers: { "Authorization" => "Bearer #{token}" },
        as: :json

      json = JSON.parse(response.body)
      expect(json.dig("data", "me", "email")).to eq(user.email)
      expect(json.dig("data", "me", "id")).to eq(user.id.to_s)
    end
  end

  context "未認証の場合" do
    it "null を返す" do
      post "/graphql", params: { query: query }, as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "me")).to be_nil
    end
  end
end
