# rails-sandbox

Rails 8.1 + PostgreSQL のサンドボックスプロジェクト。

## 必要なもの

- Docker / Docker Compose

## セットアップ

```bash
# 1. リポジトリをクローン
git clone <repo-url>
cd rails-sandbox

# 2. 環境変数ファイルを作成
cp .env.example .env

# 3. イメージをビルド
docker compose build

# 4. コンテナを起動
docker compose up -d

# 5. DB セットアップ
docker compose exec web bin/rails db:create db:migrate
```

## 開発

```bash
# サーバー起動（docker compose up -d 後）
# → http://localhost:3000

# Rails コンソール
docker compose exec web bin/rails console

# マイグレーション実行
docker compose exec web bin/rails db:migrate

# テスト実行
docker compose exec web bin/rails test
```

## 環境変数

`.env.example` を参照。`.env` にコピーして使用する。

## デプロイ

Kamal を使用。`config/deploy.yml` を参照。
