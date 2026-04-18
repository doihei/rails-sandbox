# rails-sandbox

Rails 8.1 + PostgreSQL のサンドボックスプロジェクト。

## 開発環境

**ローカルの Ruby / PostgreSQL は使わない。docker-compose で全て動かす。**

## 主要コマンド

```bash
# 環境起動
docker compose up -d

# Rails コマンド実行
docker compose exec app bin/rails <コマンド>
docker compose exec app bin/rails db:migrate
docker compose exec app bin/rails console

# 環境停止
docker compose down

# ログ確認
docker compose logs -f app
```

## ファイル構成メモ

- `docker/Dockerfile` — 本番用 Dockerfile（Kamal デプロイ用）
- `docker/Dockerfile.dev` — 開発用 Dockerfile（docker-compose 用）
- `bin/docker-entrypoint` — 起動スクリプト。server.pid の削除・db:prepare を自動実行
- `.env` — DB 接続情報（gitignore 対象）
- `.env.example` — `.env` のテンプレート
- `.claude/rules/docker.md` — Docker構成のコンテキストルール（Claude向け）
- `.claude/skills/` — プロジェクト固有の Claude スキル
- `.devcontainer/` — VSCode Dev Container 設定（docker-compose の app サービスに接続）
- `docker/nginx.conf` — Nginx設定（Nginx → Puma のリバースプロキシ）
- `.vscode/tasks.json` — VSCode タスク設定（docker compose 経由でテスト実行）

## トラブルシューティング

### コンテナ再起動時に "A server is already running" が出る場合

`tmp/pids/server.pid` が残っている。`bin/docker-entrypoint` 内で自動削除されるが、手動で解消する場合：

```bash
rm tmp/pids/server.pid
```
