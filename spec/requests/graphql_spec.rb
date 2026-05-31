require "rails_helper"

RSpec.describe "GraphQL", type: :request do
  let(:user) { create(:user) }
  let!(:article) { create(:article, :published, user: user) }

  describe "Query: articles" do
    let(:query) do
      <<~GQL
        query {
          articles {
            id
            title
            status
          }
        }
      GQL
    end

    it "記事一覧を返す" do
      post "/graphql", params: { query: query }, as: :json
      json = JSON.parse(response.body)
      expect(json.dig("data", "articles")).to be_an(Array)
      expect(json.dig("data", "articles").first["title"]).to eq(article.title)
    end
  end

  describe "Query: article(id:)" do
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

  describe "Mutation: createArticle" do
    let(:mutation) do
      <<~GQL
        mutation {
          createArticle(input: { title: "テスト記事", body: "本文" }) {
            article { id title }
            errors
          }
        }
      GQL
    end

    context "未ログインの場合" do
      it "errors を返す" do
        post "/graphql", params: { query: mutation }, as: :json
        json = JSON.parse(response.body)
        expect(json.dig("data", "createArticle", "errors")).not_to be_empty
      end
    end

    context "ログイン済みの場合" do
      it "記事が作成される" do
        # GraphQL はセッション経由でログインする
        sign_in user
        expect {
          post "/graphql", params: { query: mutation }, as: :json
        }.to change(Article, :count).by(1)
      end
    end
  end
end
