---
paths:
  - "test/**/*"
  - "spec/**/*"
---

## テスト実行規約

### フレームワーク方針

- **新規テストは RSpec で書く**。Minitest は既存テストの維持のみ（将来的に RSpec へ完全移行予定）
- テストは必ずコンテナ経由で実行する（ローカル Ruby は使わない）
- VSCode では `.vscode/tasks.json` に Minitest / RSpec 両方のタスクが定義済み

---

## RSpec（新規テストはこちら）

- 実行コマンド: `docker compose exec app bundle exec rspec`
- ファイル配置: `spec/models/`、`spec/factories/`
- データ生成は FactoryBot（`spec/factories/*.rb`）。fixtures は使わない
- DatabaseCleaner が設定済み（`spec/rails_helper.rb`）。`use_transactional_fixtures` は無効にして DatabaseCleaner に委譲
- `spec/rails_helper.rb` に以下を include 済み。新規 spec では追加不要:
  - `FactoryBot::Syntax::Methods`（`create` / `build` をそのまま使える）

---

## Minitest（既存テストの維持のみ）

- テストは必ず `docker compose exec app bin/rails test` 経由で実行する
- テストフレームワークは minitest（Rails 標準）
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

### フィクスチャの counter_cache カラム

fixtures はコールバックを経由しないため、counter_cache カラム（`comments_count`、`tags_count` など）は自動で更新されない。
実際の関連レコード数と一致する値を fixture に明示する：

```yml
# comments が 2 件・tags が 2 件ある場合
one:
  comments_count: 2
  tags_count: 2
```

未設定（0のまま）だと、`comments_count` を参照するスコープ（`popular` など）のテストで実際の件数とズレが生じる。

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
