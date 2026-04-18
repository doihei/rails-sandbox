## Docker 構成

### サービス構成（docker-compose.yml）
- `app`: Rails アプリ（Puma、内部ポート 3000。外部には公開しない）
- `nginx`: リバースプロキシ（ホスト 8080 → コンテナ 80 → app:3000）
- `db`: PostgreSQL 17（ポート 5432）

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
