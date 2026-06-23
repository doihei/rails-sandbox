require "rails_helper"

RSpec.describe "Mutation: deleteComment", type: :request do
  let(:owner)   { create(:user) }
  let(:other)   { create(:user) }
  let(:article) { create(:article) }
  let!(:comment) { create(:comment, article: article, user: owner) }

  def auth_headers(user)
    { "Authorization" => "Bearer #{JwtService.encode(user_id: user.id)}" }
  end

  def mutation(id)
    <<~GQL
      mutation { deleteComment(input: { id: "#{id}" }) { success errors } }
    GQL
  end

  it "オーナーは削除できる" do
    expect {
      post "/graphql",
        params: { query: mutation(comment.id) },
        headers: auth_headers(owner),
        as: :json
    }.to change(Comment, :count).by(-1)
  end

  it "別ユーザーは削除できない" do
    post "/graphql",
      params: { query: mutation(comment.id) },
      headers: auth_headers(other),
      as: :json
    json = JSON.parse(response.body)
    expect(json.dig("data", "deleteComment", "errors")).not_to be_empty
  end
end
