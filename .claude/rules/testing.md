---
paths:
  - "spec/**/*"
---

## テスト実行規約

### フレームワーク方針

- **テストフレームワークは RSpec のみ**。Minitest は削除済み。
- テストは必ずコンテナ経由で実行する（ローカル Ruby は使わない）
- VSCode では `.vscode/tasks.json` に RSpec タスクが定義済み

---

## RSpec

- 実行コマンド: `docker compose exec app bundle exec rspec`
- ファイル配置:
  - モデル: `spec/models/`
  - サービス: `spec/services/<namespace>/`
  - ジョブ: `spec/jobs/`
  - リクエスト（コントローラ相当）: `spec/requests/`
  - GraphQL: `spec/requests/graphql/queries/`（Query）、`spec/requests/graphql/mutations/`（Mutation）
  - ファクトリ: `spec/factories/`
- データ生成は FactoryBot（`spec/factories/*.rb`）。fixtures は使わない
- DB クリーンアップは `use_transactional_fixtures = true`（各テスト後にトランザクションをロールバック）で管理
- `ENV['RAILS_ENV'] = 'test'` を強制設定済み（コンテナ内の `RAILS_ENV=development` を上書き）
- `spec/rails_helper.rb` に以下を include 済み。新規 spec では追加不要:
  - `FactoryBot::Syntax::Methods`（`create` / `build` をそのまま使える）
  - `Devise::Test::IntegrationHelpers`（`type: :request` の spec でログイン可能）
  - `ActiveJob::TestHelper`（`have_enqueued_job` / `perform_enqueued_jobs` を使う場合）
### RSpec の type 別メモ

| type | 配置先 | 継承元 |
|---|---|---|
| `:model` | `spec/models/` | `RSpec::Rails` の model helper |
| `:request` | `spec/requests/` | `ActionDispatch::Integration` |
| `:job` | `spec/jobs/` | `ActiveJob::TestHelper` |

### counter_cache カラムのテスト

FactoryBot は `after(:create)` コールバックを経由するため counter_cache は自動更新される。
`create` / `destroy` で変化を確認する際は `reload` を使う:

```ruby
expect { create(:comment, article: article) }
  .to change { article.reload.comments_count }.by(1)
```

### `let` の遅延評価に注意

`expect { action }.to change(Model, :count).by(n)` の中で初めて `let` が評価されると、
作成と削除がキャンセルされてカウントが変わらない。事前に参照するか `let!` を使う:

```ruby
# NG: comment が block 内で初めて評価されると count 変化 = 0
it "削除できる" do
  expect { delete path(comment) }.to change(Comment, :count).by(-1)
end

# OK: block の前に comment を参照しておく
it "削除できる" do
  comment  # 事前に評価
  expect { delete path(comment) }.to change(Comment, :count).by(-1)
end

# または let! で強制評価
let!(:comment) { create(:comment, ...) }
```

### `composed_of` で管理しているカラムは文字列比較しない

```ruby
# NG
expect(article.status).to eq("published")
# OK
expect(article.status.published?).to be true
```
