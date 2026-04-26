# rails-sandbox

Rails 8.1 + PostgreSQL の学習用サンドボックス。

## 開発環境の絶対原則

- **ローカルの Ruby / PostgreSQL は使わない。docker-compose で全て動かす。**
- Rails コマンドは必ず `docker compose exec app bin/rails <コマンド>` 経由で実行する。

## コンテキストの参照先

- Docker 構成・環境変数・Kamal 連携 → `.claude/rules/docker.md`
- コミット規約 → `.claude/rules/commit-message.md`
- テスト実行規約 → `.claude/rules/testing.md`
- Solid Queue / Job の実装規約 → `.claude/rules/jobs.md`
- Service Object の実装規約 → `.claude/rules/services.md`
- Value Object の実装規約 → `.claude/rules/value_objects.md`
- Turbo Frame の規約 → `.claude/rules/turbo.md`
- 環境立ち上げ・トラブルシュート手順 → `.claude/skills/docker-compose-setup/SKILL.md`（`/docker-compose-setup` スキルで呼び出し可能）
- 人間向けセットアップガイド → `README.md`
