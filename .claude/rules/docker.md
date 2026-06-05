---
paths:
  - "Dockerfile"
  - "docker/**/*"
  - "docker-compose.yml"
  - ".devcontainer/**/*"
  - "config/deploy.yml"
  - "bin/docker-entrypoint"
  - "bin/dev"
  - "Procfile.dev"
---

## Docker 構成

### サービス構成（docker-compose.yml）
- `app`: Rails アプリ（Puma、内部ポート 3000。外部には公開しない）
- `nginx`: リバースプロキシ（ホスト 8080 → コンテナ 80 → app:3000）
- `db`: PostgreSQL 18（ポート 5432）

### Dockerfile の場所
- `docker/Dockerfile` — Cloud Run 用本番イメージ（`ruby:3.4-slim` ベース、ポート 8080）。CMD はサーバー起動のみ。migration は別途実行すること
- `docker/Dockerfile.kamal` — Kamal デプロイ用（`config/deploy.yml` の `builder.dockerfile` で参照）
- `docker/Dockerfile.dev` — 開発用（docker-compose で使用）

### Cloud Build（GCP）
- `cloudbuild.yaml` — GCP Cloud Build でイメージをビルドする設定。`docker/Dockerfile` を使用。`_SHA` substitution を必ず渡すこと（デフォルト値なし）
- ビルドコマンド: `gcloud builds submit --config=cloudbuild.yaml --substitutions=_SHA=$(git rev-parse --short HEAD) .`
- GCP デプロイ全体は `rails-sandbox-infra/deploy.sh` が一括管理する

build context はプロジェクトルート（`.`）なので、Dockerfile 内の COPY パスはルートからの相対パス。

### 環境変数
- `.env` に `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DEV_DATABASE_URL`, `TEST_DATABASE_URL` を定義
- `DEV_DATABASE_URL` により Rails の `primary` と `queue` 接続が同じDBを使う（開発環境は単一DB構成）
- `SOLID_QUEUE_IN_PUMA: true` を docker-compose の environment に設定済み（Pumaと同一プロセスでJobワーカーを起動）

### Kamal との関係
`config/deploy.yml` の `builder.dockerfile` に `docker/Dockerfile` を指定済み。
本番ビルドは Kamal が `docker/Dockerfile` を使う。

### エントリポイント
- `bin/docker-entrypoint` — 本番用（Kamal）。`server.pid` 削除 + `db:prepare` を自動実行
- `docker/dev-entrypoint` — 開発用（docker-compose）。`bundle install` + `db:prepare` + solid_queue テーブル初期化 + `server.pid` 削除
- `bin/dev` — foreman 経由で `Procfile.dev` を起動するシェルスクリプト。web（Puma）と css（Tailwind watch）を並列起動する

### Procfile.dev
foreman が読む開発用プロセス定義。現在の構成:
- `web`: `bin/rails server -b 0.0.0.0`
- `css`: `bin/rails tailwindcss:watch[always]`（`always` 必須。Docker では stdin が即閉じるため `always` なしだとビルド1回で終了する）

### 関連ファイル
- `.env` / `.env.example` — DB 接続情報（`.env` は gitignore 対象）
- `docker/nginx.conf` — Nginx → Puma リバースプロキシ設定
- `Procfile.dev` — foreman が読む開発用プロセス定義（web + css）
- `.devcontainer/` — docker-compose の `app` サービスに接続する VSCode Dev Container 設定
- `.vscode/tasks.json` — docker compose 経由でテスト実行するタスク定義
