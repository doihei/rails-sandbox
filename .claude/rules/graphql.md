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
    <model>_type.rb             # 各モデルの型定義
  mutations/
    base_mutation.rb
    authenticated_mutation.rb   # ログイン必須 Mutation の基底クラス（ready? で認証チェック）
    <action>_<resource>.rb      # Mutation 実装（例: create_article.rb）
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

ログイン必須の Mutation は `BaseMutation` ではなく `AuthenticatedMutation` を継承する。
`ready?` フックで `resolve` より前に認証チェックが走るため、`resolve` 内で `context[:current_user]` を確認する必要はない。

```ruby
module Mutations
  class CreateArticle < Mutations::AuthenticatedMutation  # ← ログイン必須
    # 引数定義
    argument :title, String, required: true

    # 返却フィールド（errors は必ず含める）
    field :article, Types::ArticleType, null: true
    field :errors, [String], null: false

    def resolve(title:)
      # 1. レコード取得（存在しない場合は早期終了）
      # article = Article.find_by(id: id)
      # return { article: nil, errors: [I18n.t("articles.errors.not_found")] } unless article

      # 2. Service Object に処理を委譲（認可・ビジネスロジックはサービス内）
      result = Articles::CreateService.call(user: current_user, ...)

      if result.success?
        { article: result.value, errors: [] }
      else
        { article: nil, errors: [result.error] }
      end
    end
  end
end
```

ログイン不要の Mutation（`CreateSession` 等）は従来どおり `BaseMutation` を継承する。

**`AuthenticatedMutation` の仕組み：**

```ruby
class AuthenticatedMutation < BaseMutation
  def ready?(**_args)
    return [false, { errors: [I18n.t("errors.login_required")] }] unless current_user
    super
  end

  private

  def current_user = context[:current_user]
end
```

- 未認証時は `resolve` を呼ばず `{ errors: [...] }` を返す
- `current_user` ヘルパーで `context[:current_user]` を参照できる（`resolve` 内でも使用可）

**認証 vs 認可の責務分離：**

| 層 | 責務 |
|---|---|
| `AuthenticatedMutation#ready?` | **認証** — `current_user` の存在確認 |
| Mutation (`resolve`) | レコードの存在確認 |
| Service | **認可** — `current_user` がその操作をしてよいか（オーナーチェック等） |

Service は「呼ばれた時点で `current_user` は必ず存在する」前提で動く。Service 内で `current_user` の nil チェックは行わない。

**`success` フィールドの null 制約：**
削除系 Mutation の `field :success, Boolean` は `null: true` にする。未認証時に `ready?` が `{ errors: [...] }` を返す際、`success` キーが欠落するため `null: false` だと制約違反になる。

### Query フィールドの命名

- 複数形（一覧）: `field :articles, [Types::ArticleType], null: false`
- 単数形（1件）: `field :article, Types::ArticleType, null: true`（引数 `id` 必須）
- 認証ユーザー自身: `field :me, Types::UserType, null: true`（未認証時は `null`、`context[:current_user]` を返す）

### Relay Connection（ページネーション付き一覧）

一覧をページネーション付きで返す場合は `connection_type` を使う。

```ruby
field :articles, Types::ArticleType.connection_type, null: false
```

**注意点：**

- `connection_type` は `first` / `after` / `last` / `before` 引数を**自動追加**する。
  フィールド定義で手動宣言すると `DuplicateNamesError` になる。

  ```ruby
  # NG: first/after を手動宣言すると DuplicateNamesError
  field :tagged_articles, Types::ArticleType.connection_type, null: false do
    argument :tag_id, ID, required: true
    argument :first,  Integer, required: false  # ← 重複!
    argument :after,  String,  required: false  # ← 重複!
  end

  # OK: ドメイン固有の引数だけ宣言する
  field :tagged_articles, Types::ArticleType.connection_type, null: false do
    argument :tag_id, ID, required: true
  end
  ```

- `Types::ArticleConnectionType` のような独自定数名は graphql-ruby が自動生成しない。
  未定義定数エラーを避けるため、必ず `Types::ArticleType.connection_type` の形式を使うこと。

### エラーメッセージの i18n

Mutation 内のエラーメッセージはハードコードせず `I18n.t()` を使う。

| キー | 用途 |
|---|---|
| `errors.login_required` | 未認証 |
| `errors.unauthorized` | 認可エラー（オーナー以外の操作） |
| `errors.stale_object` | 楽観的ロック競合 |
| `<resource>.errors.not_found` | レコードが存在しない（例: `articles.errors.not_found`） |

共通キー（`errors.*`）はルートの `config/locales/ja.yml` に、リソース固有キーはサブディレクトリのロケールファイル（例: `config/locales/articles/ja.yml`）に定義する。

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

### JWT 認証

GraphQL リクエストの認証は JWT のみ（Devise セッションは不使用）。

- `GraphqlController` は `Authorization: Bearer <token>` ヘッダから `current_user` を解決する
- トークン取得: `createSession` Mutation を呼び出して `token` を受け取る
- ログアウト: クライアント側でトークンを破棄する（サーバー側での無効化なし）
- `context[:current_user]` が `nil` の場合、`AuthenticatedMutation` が `ready?` で自動的に `errors.login_required` を返す

**テストでの認証:**

```ruby
token = JwtService.encode(user_id: user.id)
post "/graphql",
  params: { query: mutation },
  headers: { "Authorization" => "Bearer #{token}" },
  as: :json
```

### CORS / CSRF 設定

`config/initializers/cors.rb` で rack-cors によるCORS設定を行う。
デフォルトでは `http://localhost:3000` から `/graphql` への POST / OPTIONS を許可している。
複数のオリジンを許可する場合は `ALLOWED_ORIGINS` 環境変数にカンマ区切りで設定する（例: `ALLOWED_ORIGINS=http://localhost:3000,https://example.com`）。

`GraphqlController` では `protect_from_forgery with: :null_session` を設定しており、
外部クライアント（フロントエンドSPA等）からCSRFトークンなしにリクエストできる。
