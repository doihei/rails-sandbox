---
paths:
  - "docker/**/*"
  - "docker-compose.yml"
  - ".devcontainer/**/*"
  - "config/deploy.yml"
  - "bin/docker-entrypoint"
---

## Docker 構成

### サービス構成（docker-compose.yml）
- `app`: Rails アプリ（Puma、内部ポート 3000。外部には公開しない）
- `nginx`: リバースプロキシ（ホスト 8080 → コンテナ 80 → app:3000）
- `db`: PostgreSQL 18（ポート 5432）

### Dockerfile の場所
- `docker/Dockerfile` — 本番用（Kamal デプロイ時に使用）
- `docker/Dockerfile.dev` — 開発用（docker-compose で使用）

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
- `docker/dev-entrypoint` — 開発用（docker-compose）。`db:prepare` + solid_queue テーブル初期化 + `server.pid` 削除

### 関連ファイル
- `.env` / `.env.example` — DB 接続情報（`.env` は gitignore 対象）
- `docker/nginx.conf` — Nginx → Puma リバースプロキシ設定
- `.devcontainer/` — docker-compose の `app` サービスに接続する VSCode Dev Container 設定
- `.vscode/tasks.json` — docker compose 経由でテスト実行するタスク定義
