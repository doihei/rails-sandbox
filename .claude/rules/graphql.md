---
paths:
  - "app/graphql/**/*.rb"
  - "app/controllers/graphql_controller.rb"
  - "config/routes.rb"
---

## GraphQL API 実装規約

このプロジェクトは `graphql-ruby` を使用し、`app/graphql/` 配下にスキーマを管理する。

### ディレクトリ構成

```
app/graphql/
  rails_sandbox_schema.rb       # スキーマ定義
  types/
    query_type.rb               # Query ルートフィールド
    mutation_type.rb            # Mutation ルートフィールド
    article_type.rb             # 各モデルの型定義
    ...
  mutations/
    base_mutation.rb
    create_article.rb           # Mutation 実装
  sources/
    record_by_id.rb             # belongs_to 用 Dataloader Source
    association_loader.rb       # has_many / has_many :through 用 Dataloader Source
  resolvers/
    base_resolver.rb
```

### N+1 対策：Dataloader Source の使い分け

| アソシエーション種別 | 使用する Source | 呼び出し例 |
|---|---|---|
| `belongs_to`（単一レコード取得） | `Sources::RecordById` | `dataloader.with(Sources::RecordById, User).load(object.user_id)` |
| `has_many` / `has_many :through` | `Sources::AssociationLoader` | `dataloader.with(Sources::AssociationLoader, :tags).load(object)` |

**`Sources::RecordById`**: モデルと ID のリストを受け取り、`WHERE id IN (...)` で一括取得する。

**`Sources::AssociationLoader`**: アソシエーション名を受け取り、`ActiveRecord::Associations::Preloader` で一括プリロードする。

### Mutation の実装パターン

```ruby
module Mutations
  class CreateArticle < Mutations::BaseMutation
    # 引数定義
    argument :title, String, required: true

    # 返却フィールド（errors は必ず含める）
    field :article, Types::ArticleType, null: true
    field :errors, [String], null: false

    def resolve(title:)
      # 認証チェックは return で早期終了する（unless + return を1行で書く）
      return { article: nil, errors: [I18n.t("errors.login_required")] } unless context[:current_user]

      # Service Object に処理を委譲する
      result = Articles::CreateService.call(...)

      if result.success?
        { article: result.value, errors: [] }
      else
        { article: nil, errors: [result.error] }
      end
    end
  end
end
```

### Query フィールドの命名

- 複数形（一覧）: `field :articles, [Types::ArticleType], null: false`
- 単数形（1件）: `field :article, Types::ArticleType, null: true`（引数 `id` 必須）

### エラーメッセージの i18n

Mutation 内のエラーメッセージはハードコードせず `I18n.t()` を使う。
共通エラーキーは `config/locales/ja.yml` の `errors:` 配下に定義する。

```yaml
ja:
  errors:
    login_required: "ログインが必要です"
```

### GraphiQL

開発環境では `http://localhost:8080/graphiql` から GraphiQL UI にアクセスできる。
`config/routes.rb` で `Rails.env.development?` の条件付きマウントとなっている。

### Apollo Federation 対応

このスキーマは Apollo Federation のサブグラフとして動作する。

**スキーマへの組み込み：**

```ruby
class RailsSandboxSchema < GraphQL::Schema
  include ApolloFederation::Schema
  ...
end
```

**型をエンティティとして公開する：**

```ruby
class ArticleType < Types::BaseObject
  include ApolloFederation::Object
  key fields: "id"

  # resolve_references（複数形）で一括取得 → WHERE id IN (...) の1クエリ
  # resolve_reference（単数形）は使わない — N件クエリが発生する
  def self.resolve_references(references, _context)
    ids = references.map { |r| r[:id].to_i }
    articles = Article.where(id: ids).index_by(&:id)
    references.map { |r| articles[r[:id].to_i] }
  end
end
```

**注意：** `resolve_reference`（単数）は `references.map` で個別呼び出しになり Dataloader がバッチできないため、必ず `resolve_references`（複数）を使うこと。

### CORS / CSRF 設定

`config/initializers/cors.rb` で rack-cors によるCORS設定を行う。
デフォルトでは `http://localhost:3000` から `/graphql` への POST を許可している。

`GraphqlController` では `protect_from_forgery with: :null_session` を設定しており、
外部クライアント（フロントエンドSPA等）からCSRFトークンなしにリクエストできる。
