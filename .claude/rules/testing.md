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
- クラスレベルでキャッシュを持つ VO（`NgWordPolicy` など）はテスト間でキャッシュが残るため、`rails_helper.rb` の `RSpec.configure` ブロック内でリセット処理を追加すること:
  ```ruby
  ValueObjects::NgWordPolicy.instance_variable_set(:@config, nil)
  ```
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

### WebMock（外部 HTTP のスタブ）

`spec/rails_helper.rb` で `require 'webmock/rspec'` を読み込み済み。**テスト中は実 HTTP 接続が無効**になる。
外部サービス（notification-service）を呼び出す spec では必ず `stub_request` を書くこと。無いと `WebMock::NetConnectNotAllowedError` で落ちる。

**重要な落とし穴**: スタブ URL はハードコードせず `NotificationClient::BASE_URL` を参照する。
`NOTIFICATION_SERVICE_URL` 環境変数で接続先が変わる（ローカルは `http://host.docker.internal:3001`）ため、
`http://localhost:3001` のようにハードコードするとスタブが一致せず失敗する。

```ruby
before do
  stub_request(:post, "#{NotificationClient::BASE_URL}/api/v1/notifications")
    .to_return(status: 201, body: { notification: { id: 1 } }.to_json)
end
```

既存実装の参照: `spec/services/notification_client_spec.rb`、`spec/jobs/article_notification_job_spec.rb`。

なお `Articles::CreateService` 系の spec はテスト中に HTTP を発生させない（`ArticleNotificationJob.perform_later` で
ジョブをキューイングするだけで `NotificationClient` を直接呼ばない）。通知の HTTP は Job spec 側でスタブして検証する。
