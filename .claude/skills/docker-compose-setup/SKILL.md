---
name: docker-compose-setup
description: Guides you step-by-step through setting up the docker-compose development environment for this Rails project: build, start containers, and run DB setup/migrations. Use this skill whenever the user wants to start the docker-compose environment, run docker compose build/up, set up the database, or troubleshoot docker-compose errors such as port conflicts, container crashes, DB connection failures, or build errors. Even if the user just says "docker-composeで環境立ち上げたい" or "docker compose うまくいかない", use this skill.
---

# docker-compose 環境構築（Rails）

このプロジェクト（Rails + PostgreSQL）の docker-compose 環境を順番に立ち上げる。各ステップを実行し、エラーが出たらその場でトラブルシューティングを行う。

## 基本フロー

```
Step 1: docker compose build
Step 2: docker compose up -d
Step 3: bin/rails db:create db:migrate
```

---

## Step 1: docker compose build

```bash
docker compose build
```

### よくあるエラーと対処

**パッケージが見つからない**
```
E: Unable to locate package <name>
```
→ `docker/Dockerfile.dev` の `apt-get install` に該当パッケージがない、またはリポジトリが古い。`apt-get update` が `install` の前にあるか確認する。

**gem が見つからない**
```
Bundler::GemNotFound / Could not find gem
```
→ `Gemfile.lock` と Dockerfile の環境が合っていない。ホスト側で `bundle install` を実行して `Gemfile.lock` を更新してからリビルド。
```bash
bundle install
docker compose build
```

**ファイルが存在しない**
```
COPY failed: file not found in build context
```
→ Dockerfile が参照しているファイルのパスを確認する。`docker-compose.yml` の `context:` がプロジェクトルートになっているか確認。

**ネットワーク / Docker Hub の障害**
```
ERROR [internal] load metadata for docker.io/...
```
→ `docker login` でログインしているか確認。または少し待ってリトライ。

---

## Step 2: docker compose up -d

```bash
docker compose up -d
```

起動後に `docker compose ps` でステータスを確認する。全サービスが `running` になっていればOK。

### よくあるエラーと対処

**ポートが競合している**
```
Bind for 0.0.0.0:5432 failed: port is already allocated
```
→ Homebrew の PostgreSQL が起動中の可能性が高い。
```bash
brew services list | grep postgresql   # 起動中か確認
brew services stop postgresql@XX       # 停止
docker compose up -d                   # リトライ
```
それ以外のポートの場合:
```bash
lsof -i :XXXX  # 使用中のプロセスを確認して停止する
```

**コンテナがすぐに終了する**
```
Exited (1)  # docker compose ps で確認
```
→ ログを確認する。
```bash
docker compose logs web
docker compose logs db
```

**"A server is already running" が出る**
```
A server is already running (pid: 1, file: /rails/tmp/pids/server.pid).
```
→ entrypoint が自動で削除するが、手動でも解消できる。
```bash
rm tmp/pids/server.pid
docker compose up -d
```

**`.env` ファイルがない / 環境変数が不足している**
```
env file .env not found
```
→ `.env.example` をコピーして `.env` を作成する。
```bash
cp .env.example .env
```

**ネットワークが見つからない**
```
network xxx not found
```
→ 一度クリーンにしてから再起動。
```bash
docker compose down
docker compose up -d
```

---

## Step 3: DB セットアップ

> **補足：** `docker compose up` 時に `bin/docker-entrypoint` が `db:prepare`（= create + migrate）を自動実行するため、初回起動後はこの手順は不要です。マイグレーションを手動で追加実行したい場合に使います。

```bash
docker compose exec web bin/rails db:create db:migrate
```

シードデータが必要な場合:
```bash
docker compose exec web bin/rails db:seed
```

### よくあるエラーと対処

**DB に接続できない**
```
PG::ConnectionBad: could not connect to server
ActiveRecord::DatabaseConnectionError
```
→ DB コンテナがまだ起動中の可能性がある。少し待ってからリトライ。
```bash
docker compose ps        # db が running か確認
docker compose logs db   # エラーがないか確認
docker compose exec web bin/rails db:create db:migrate  # リトライ
```

**ロールが存在しない**
```
FATAL: role "xxx" does not exist
```
→ `.env` の `POSTGRES_USER` と `DATABASE_URL` のユーザー名が一致しているか確認する。

**データベースが存在しない**
```
ActiveRecord::NoDatabaseError
FATAL: database "xxx" does not exist
```
→ `db:create` が先に必要。
```bash
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate
```

**マイグレーション未実行**
```
ActiveRecord::PendingMigrationError
```
→ マイグレーションを実行する。
```bash
docker compose exec web bin/rails db:migrate
```

**コンテナが見つからない**
```
Error response from daemon: No such container
```
→ コンテナが起動していない。
```bash
docker compose up -d
```

---

## 完了確認

```bash
docker compose ps          # 全サービスが running か
docker compose logs -f web # サーバーログをフォロー
```

`http://localhost:3000` にアクセスして動作確認する。

---

## よく使うコマンド

```bash
# 停止
docker compose down

# ログ確認
docker compose logs -f
docker compose logs -f web

# Rails コマンド実行
docker compose exec web bin/rails console
docker compose exec web bin/rails db:migrate

# 全削除してやり直し（DBデータも消える）
docker compose down -v
docker compose build --no-cache
docker compose up -d
```
