# spec/requests/graphql/mutations/toggle_like_spec.rb
require "rails_helper"

RSpec.describe "Mutation: toggleLike", type: :request do
  let(:user)    { create(:user) }
  let(:article) { create(:article) }

  def auth_headers(user)
    { "Authorization" => "Bearer #{JwtService.encode(user_id: user.id)}" }
  end

  def mutation(likeable_id:, likeable_type:)
    <<~GQL
      mutation {
        toggleLike(input: {
          likeableId: "#{likeable_id}",
          likeableType: "#{likeable_type}"
        }) {
          liked
          likesCount
          errors
        }
      }
    GQL
  end

  context "未認証" do
    it "errors を返す" do
      post "/graphql",
        params: { query: mutation(likeable_id: article.id, likeable_type: "Article") },
        as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "toggleLike", "errors")).not_to be_empty
    end
  end

  context "記事へのいいね" do
    it "初回: liked: true / likes_count: 1 を返す" do
      post "/graphql",
        params: { query: mutation(likeable_id: article.id, likeable_type: "Article") },
        headers: auth_headers(user),
        as: :json
      json = JSON.parse(response.body)
      result = json.dig("data", "toggleLike")
      expect(result["liked"]).to be true
      expect(result["likesCount"]).to eq(1)
    end

    it "2回目: liked: false / likes_count: 0 を返す（取り消し）" do
      create(:like, user: user, likeable: article)
      post "/graphql",
        params: { query: mutation(likeable_id: article.id, likeable_type: "Article") },
        headers: auth_headers(user),
        as: :json
      json = JSON.parse(response.body)
      result = json.dig("data", "toggleLike")
      expect(result["liked"]).to be false
      expect(result["likesCount"]).to eq(0)
    end
  end

  context "コメントへのいいね" do
    let(:comment) { create(:comment, article: article) }

    it "liked: true を返す" do
      post "/graphql",
        params: { query: mutation(likeable_id: comment.id, likeable_type: "Comment") },
        headers: auth_headers(user),
        as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "toggleLike", "liked")).to be true
    end
  end

  context "不正な likeableType" do
    it "errors を返す" do
      post "/graphql",
        params: { query: mutation(likeable_id: 1, likeable_type: "User") },
        headers: auth_headers(user),
        as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "toggleLike", "errors")).not_to be_empty
    end
  end
end
