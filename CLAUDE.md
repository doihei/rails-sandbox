# rails-sandbox

Rails 8.1 + PostgreSQL のサンドボックスプロジェクト。

## 開発環境

**ローカルの Ruby / PostgreSQL は使わない。docker-compose で全て動かす。**

## 主要コマンド

```bash
# 環境起動
docker compose up -d

# Rails コマンド実行
docker compose exec web bin/rails <コマンド>
docker compose exec web bin/rails db:migrate
docker compose exec web bin/rails console

# 環境停止
docker compose down

# ログ確認
docker compose logs -f web
```

## ファイル構成メモ

- `docker/Dockerfile` — 本番用 Dockerfile（Kamal デプロイ用）
- `docker/Dockerfile.dev` — 開発用 Dockerfile（docker-compose 用）
- `.env` — DB 接続情報（gitignore 対象）
- `.env.example` — `.env` のテンプレート
- `.claude/rules/docker.md` — Docker構成のコンテキストルール（Claude向け）
- `.claude/skills/` — プロジェクト固有の Claude スキル
