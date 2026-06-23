require "rails_helper"

RSpec.describe "Mutation: createComment", type: :request do
  let(:user)    { create(:user) }
  let(:article) { create(:article) }

  def auth_headers(user)
    token = JwtService.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  let(:mutation) do
    <<~GQL
      mutation {
        createComment(input: { articleId: "#{article.id}", body: "テストコメント" }) {
          comment { id body }
          errors
        }
      }
    GQL
  end

  context "未認証" do
    it "errors を返す" do
      post "/graphql", params: { query: mutation }, as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "createComment", "errors")).not_to be_empty
    end
  end

  context "認証済み" do
    it "コメントが作成される" do
      expect {
        post "/graphql",
          params: { query: mutation },
          headers: auth_headers(user),
          as: :json
      }.to change(Comment, :count).by(1)
    end

    it "body が返る" do
      post "/graphql",
        params: { query: mutation },
        headers: auth_headers(user),
        as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "createComment", "comment", "body")).to eq("テストコメント")
    end
  end
end
