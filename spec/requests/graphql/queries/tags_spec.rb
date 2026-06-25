require "rails_helper"

RSpec.describe "Query: tags", type: :request do
  let!(:rails_tag) { create(:tag, name: "rails") }
  let!(:article)   { create(:article) }

  before { article.tags << rails_tag }

  let(:query) do
    <<~GQL
      query { tags { id name articlesCount } }
    GQL
  end

  it "タグ一覧が返る" do
    post "/graphql", params: { query: query }, as: :json
    json = JSON.parse(response.body)
    tags = json.dig("data", "tags")
    expect(tags.first["name"]).to eq("rails")
    expect(tags.first["articlesCount"]).to eq(1)
  end
end
