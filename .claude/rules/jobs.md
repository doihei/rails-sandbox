---
paths:
  - "app/jobs/**/*.rb"
  - "test/jobs/**/*.rb"
---

## Solid Queue / Job の規約

- Queue バックエンドは Solid Queue。開発・小規模本番では `SOLID_QUEUE_IN_PUMA: true`（docker-compose で設定済み）により Puma と同一プロセスでワーカーを起動する。別プロセス不要。
- Job 実装では必ず `retry_on` と `discard_on` を明示する:
  - `retry_on StandardError, wait: :polynomially_longer, attempts: 3`
  - `discard_on ActiveRecord::RecordNotFound`（削除済みレコードで無限リトライさせない）
- 既存実装の参照: `app/jobs/article_notification_job.rb`
