---
paths:
  - "test/**/*"
---

## テスト実行規約

- テストは必ず `docker compose exec app bin/rails test` 経由で実行する（ローカル Ruby は使わない）
- テストフレームワークは minitest（Rails 標準）。RSpec は使わない。
- データ生成は fixtures (`test/fixtures/*.yml`)。factory_bot は使わない。
- `test/test_helper.rb` に以下を include 済み。新規テストでは追加不要:
  - `Devise::Test::IntegrationHelpers`（ログイン必須のコントローラテスト用）
  - `ActiveJob::TestHelper`（`assert_enqueued_with` などを使う場合）
- Service Object のテストは `test/services/<namespace>/` に配置する（`ActiveSupport::TestCase` を継承）
- Value Object のテストは `test/models/value_objects/` に配置する（`ActiveSupport::TestCase` を継承）
- VSCode では `.vscode/tasks.json` に docker compose 経由のテストタスクが定義済み
