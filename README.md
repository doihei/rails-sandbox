# rails-sandbox

Rails 8.1 + PostgreSQL のサンドボックスプロジェクト。

## 必要なもの

- Docker / Docker Compose

## セットアップ

### Dev Container（推奨）

VSCode + [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 拡張をインストール後、リポジトリを開き「Reopen in Container」を選択。

### 通常セットアップ

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
docker compose exec app bin/rails db:create db:migrate
```

## 開発

```bash
# サーバー起動（docker compose up -d 後）
# → http://localhost:8080 （Nginx経由）

# Rails コンソール
docker compose exec app bin/rails console

# マイグレーション実行
docker compose exec app bin/rails db:migrate

# テスト実行
docker compose exec app bin/rails test
```

## 環境変数

`.env.example` を参照。`.env` にコピーして使用する。

## デプロイ

Kamal を使用。`config/deploy.yml` を参照。
