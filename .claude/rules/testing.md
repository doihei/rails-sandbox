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
- コントローラテストは `ActionDispatch::IntegrationTest` を継承する（URL ヘルパーを使うため）
  - `ActionController::TestCase` は URL ヘルパーが使えず `UrlGenerationError` になる
- 統合テスト内で翻訳文字列を比較する場合は `t()` ではなく `I18n.t()` を使う
- Service Object のテストは `test/services/<namespace>/` に配置する（`ActiveSupport::TestCase` を継承）
- Value Object のテストは `test/models/value_objects/` に配置する（`ActiveSupport::TestCase` を継承）
- ViewComponent のテストは `test/components/<namespace>/` に配置する（`ViewComponent::TestCase` を継承）
- `composed_of` で VO 管理しているカラムはテスト内でも文字列比較しない:
  ```ruby
  # NG
  assert_equal "published", article.status
  # OK
  assert article.status.published?
  ```
- VSCode では `.vscode/tasks.json` に docker compose 経由のテストタスクが定義済み

### フィクスチャ追加時の注意

新しいフィクスチャを追加するとき、既存の count 系テスト（`article_count_ranking` など）への影響を確認する。
特定のユーザーが「記事なし」または「記事数が少ない」ことを前提とするテストがある場合、
そのユーザーに記事フィクスチャを紐付けると順位が変わってテストが壊れる。

```yml
# NG: users(:two) が他テストで「記事なし」ユーザーとして使われている場合
new_article:
  user: two

# OK: 専用のユーザーフィクスチャ（three など）を追加して紐付ける
three:
  name: user3
  email: user3@example.com
  encrypted_password: ...

new_article:
  user: three
```
