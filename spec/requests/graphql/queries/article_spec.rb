require "rails_helper"

RSpec.describe "Query: article(id:)", type: :request do
  let(:user) { create(:user) }
  let!(:article) { create(:article, :published, user: user) }

  let(:query) do
    <<~GQL
      query {
        article(id: "#{article.id}") {
          id
          title
        }
      }
    GQL
  end

  it "指定した記事を返す" do
    post "/graphql", params: { query: query }, as: :json
    json = JSON.parse(response.body)
    expect(json.dig("data", "article", "title")).to eq(article.title)
  end

  it "存在しない id は null を返す" do
    query = 'query { article(id: "999999") { id } }'
    post "/graphql", params: { query: query }, as: :json
    json = JSON.parse(response.body)
    expect(json.dig("data", "article")).to be_nil
  end
end
