## Docker 構成

### サービス構成（docker-compose.yml）
- `web`: Rails アプリ（ポート 3000）
- `db`: PostgreSQL 17（ポート 5432）

### Dockerfile の場所
- `docker/Dockerfile` — 本番用（Kamal デプロイ時に使用）
- `docker/Dockerfile.dev` — 開発用（docker-compose で使用）

build context はプロジェクトルート（`.`）なので、Dockerfile 内の COPY パスはルートからの相対パス。

### 環境変数
- `.env` に `POSTGRES_USER`, `POSTGRES_PASSWORD`, `DEV_DATABASE_URL`, `TEST_DATABASE_URL` を定義
- `DEV_DATABASE_URL` / `TEST_DATABASE_URL` により Rails が `config/database.yml` を自動上書き
- `config/database.yml` は変更不要

### Kamal との関係
`config/deploy.yml` の `builder.dockerfile` に `docker/Dockerfile` を指定済み。
本番ビルドは Kamal が `docker/Dockerfile` を使う。
