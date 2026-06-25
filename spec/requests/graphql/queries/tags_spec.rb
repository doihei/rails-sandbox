require "rails_helper"

RSpec.describe "Query: tags", type: :request do
  let!(:rails_tag) { create(:tag, name: "rails") }
  let!(:article)   { create(:article) }

  before { article.tags << rails_tag }

  let(:query) do
    <<~GQL
      query {
        tags {
          nodes {
            id
            name
            articlesCount
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    GQL
  end

  it "タグ一覧が返る" do
    post "/graphql", params: { query: query }, as: :json
    json = JSON.parse(response.body)
    expect(json.dig("data", "tags", "nodes")).to be_an(Array)
    expect(json.dig("data", "tags", "nodes").first["name"]).to eq(rails_tag.name)
    expect(json.dig("data", "tags", "nodes").first["articlesCount"]).to eq(1)
  end
end
