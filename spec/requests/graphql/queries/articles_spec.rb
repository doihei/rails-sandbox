require "rails_helper"

RSpec.describe "Query: articles", type: :request do
  let(:user) { create(:user) }
  let!(:article) { create(:article, :published, user: user) }

  let(:query) do
    <<~GQL
      query {
        articles {
          nodes {
            id
            title
            status
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    GQL
  end

  it "記事一覧を返す" do
    post "/graphql", params: { query: query }, as: :json
    json = JSON.parse(response.body)
    expect(json.dig("data", "articles", "nodes")).to be_an(Array)
    expect(json.dig("data", "articles", "nodes").first["title"]).to eq(article.title)
  end
end
