require 'rails_helper'

RSpec.describe "Mutation: createSession", type: :request do
  let(:user) { create(:user, email: "test@example.com", password: "password123") }

  let(:mutation) do
    <<~GQL
      mutation($email: String!, $password: String!) {
        createSession(input: { email: $email, password: $password }) {
          token
          errors
        }
      }
    GQL
  end

  def post_graphql(variables)
    post "/graphql", params: { query: mutation, variables: variables }, as: :json
    JSON.parse(response.body).dig("data", "createSession")
  end

  context "正しい認証情報の場合" do
    it "JWT トークンを返す" do
      user
      result = post_graphql(email: user.email.to_s, password: "password123")
      expect(result["token"]).to be_present
      expect(result["errors"]).to be_empty
    end

    it "返ってきたトークンが valid である" do
      user
      result = post_graphql(email: user.email.to_s, password: "password123")
      payload = JwtService.decode(result["token"])
      expect(payload[:user_id]).to eq(user.id)
    end
  end

  context "パスワードが間違っている場合" do
    it "errors を返しトークンは nil" do
      user
      result = post_graphql(email: user.email.to_s, password: "wrong")
      expect(result["token"]).to be_nil
      expect(result["errors"]).to include(I18n.t("errors.invalid_credentials"))
    end
  end

  context "存在しないメールアドレスの場合" do
    it "errors を返す" do
      result = post_graphql(email: "nobody@example.com", password: "password123")
      expect(result["token"]).to be_nil
      expect(result["errors"]).to be_present
    end
  end
end
