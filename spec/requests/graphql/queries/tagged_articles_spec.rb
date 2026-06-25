require "rails_helper"

RSpec.describe "Query: taggedArticles(tagId:)", type: :request do
  let!(:tag)     { create(:tag, name: "rails") }
  let!(:other)   { create(:tag, name: "ruby") }
  let!(:article) { create(:article, :published) }
  let!(:other_article) { create(:article, :published) }

  before do
    article.tags << tag
    other_article.tags << other
  end

  def query(tag_id)
    <<~GQL
      query {
        taggedArticles(tagId: "#{tag_id}") {
          nodes { id title }
          pageInfo { hasNextPage endCursor }
        }
      }
    GQL
  end

  it "タグに紐づく記事一覧が返る" do
    post "/graphql", params: { query: query(tag.id) }, as: :json
    json = JSON.parse(response.body)
    nodes = json.dig("data", "taggedArticles", "nodes")
    expect(nodes.map { |n| n["id"] }).to contain_exactly(article.id.to_s)
  end

  it "別タグの記事は含まれない" do
    post "/graphql", params: { query: query(tag.id) }, as: :json
    json = JSON.parse(response.body)
    ids = json.dig("data", "taggedArticles", "nodes").map { |n| n["id"] }
    expect(ids).not_to include(other_article.id.to_s)
  end

  it "存在しない tagId は空リストを返す" do
    post "/graphql", params: { query: query(999_999) }, as: :json
    json = JSON.parse(response.body)
    nodes = json.dig("data", "taggedArticles", "nodes")
    expect(nodes).to be_empty
  end

  it "first でページネーションが機能する" do
    create_list(:article, 3, :published).each { |a| a.tags << tag }

    pagination_query = <<~GQL
      query {
        taggedArticles(tagId: "#{tag.id}", first: 2) {
          nodes { id }
          pageInfo { hasNextPage }
        }
      }
    GQL

    post "/graphql", params: { query: pagination_query }, as: :json
    json = JSON.parse(response.body)
    nodes = json.dig("data", "taggedArticles", "nodes")
    expect(nodes.size).to eq(2)
    expect(json.dig("data", "taggedArticles", "pageInfo", "hasNextPage")).to be true
  end
end
