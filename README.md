# rails-sandbox-backend

Rails 8.1 + GraphQL API + PostgreSQL のバックエンドサーバー。フロントエンドは `rails-sandbox-frontend`（Next.js）が担当する。

## 必要なもの

- Docker / Docker Compose

## セットアップ

### Dev Container（推奨）

VSCode + [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 拡張をインストール後、リポジトリを開き「Reopen in Container」を選択。

### 通常セットアップ

```bash
# 1. リポジトリをクローン
git clone <repo-url>
cd rails-sandbox-backend

# 2. 環境変数ファイルを作成
cp .env.example .env

# 3. イメージをビルド
docker compose build

# 4. コンテナを起動（初回起動時に DB セットアップも自動実行）
docker compose up -d
```

## 開発

```bash
# サーバー起動（docker compose up -d 後）
# → GraphQL: POST http://localhost:8080/graphql

# Rails コンソール
docker compose exec app bin/rails console

# マイグレーション実行
docker compose exec app bin/rails db:migrate

# シードデータ投入（ユーザー・記事・タグ・コメントを作成）
docker compose exec app bin/rails db:seed

# テスト実行（RSpec）
docker compose exec app bundle exec rspec
```

## GraphQL API

`docker compose up -d` 後、以下のエンドポイントが利用可能：

| 用途 | URL |
|---|---|
| GraphQL エンドポイント | `POST http://localhost:8080/graphql` |
| GraphiQL（ブラウザUI） | `http://localhost:8080/graphiql`（development のみ） |

### 認証

`createSession` Mutation でトークンを取得し、以降のリクエストに `Authorization` ヘッダで渡す。

```graphql
mutation {
  createSession(input: { email: "user@example.com", password: "password" }) {
    token
    errors
  }
}
```

取得したトークンはリクエストヘッダに付与する：

```
Authorization: Bearer <token>
```

### CORS

`config/initializers/cors.rb` により、`/graphql` への CORS を設定している。
デフォルトでは `http://localhost:3000` を許可。複数オリジンを許可する場合は `ALLOWED_ORIGINS` 環境変数にカンマ区切りで設定する。

```bash
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:4000
```

## 環境変数

`.env.example` を参照。`.env` にコピーして使用する。

## デプロイ

### Kamal（VPS）

`config/deploy.yml` を参照。

### GCP Cloud Run

`rails-sandbox-infra` リポジトリで管理。Cloud Run + Cloud SQL + Secret Manager 構成。

```bash
# rails-sandbox-infra をクローン後
cd rails-sandbox-infra
./deploy.sh  # ビルド・イメージタグ更新・terraform apply を一括実行
```

詳細は `rails-sandbox-infra/README.md` を参照。
