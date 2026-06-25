---
paths:
  - "app/services/**/*.rb"
  - "spec/services/**/*.rb"
---

## Service Object の規約

`app/services/` には性質の異なる 2 種類のクラスがある。**以下の規約は「ビジネスロジックサービス」のみが対象**。

| 種別 | 例 | 規約 |
|---|---|---|
| ビジネスロジックサービス | `Articles::PublishService` 等 | `ApplicationService` 継承・`Result` 返却・`I18n` エラー（下記） |
| 外部サービスクライアント | `NotificationClient` | 下記規約の**対象外**（別パターン。末尾参照） |

### ビジネスロジックサービス

- `ApplicationService` を継承する
- `call` クラスメソッド経由で呼び出す（`ApplicationService.call(...)` が `new(...).call` を委譲）:
  ```ruby
  result = Articles::PublishService.call(article: @article, current_user: current_user)
  ```
- 戻り値は必ず `Result` オブジェクトを返す:
  - 成功: `Result.success(value)`
  - 失敗: `Result.failure(I18n.t("errors.unauthorized"))`
  - ユーザー向けエラーメッセージは必ず `I18n.t()` を使う（ハードコード禁止）
  - 複数のサービスで共通するエラー（オーナーチェック・楽観的ロック）は `errors.*` 配下の共通キーを使う
- ビジネスロジック固有の例外はサービス内部でクラス定義して rescue する:
  ```ruby
  OwnershipError = Class.new(StandardError)
  ```
- ネームスペースはリソース名の複数形モジュールに統一する（例: `Articles::PublishService`）
- ファイル配置: `app/services/<namespace>/<action>_service.rb`
- 既存実装の参照: `app/services/articles/publish_service.rb`（公開フロー）、`app/services/articles/update_service.rb`（オーナーチェック + 楽観的ロック + タグ更新）

### Rails 8 の counter_cache × 楽観的ロック

Rails 8 では `update_counters` が `lock_version` も同時にインクリメントする（`ActiveRecord::Locking::Optimistic` がオーバーライド）。

そのため `has_many :through` の中間モデルに `counter_cache` が設定されている場合、関連レコードの作成・削除が `lock_version` を上げてしまう。

```
ArticleTag.create! → counter_cache → Article.update_counters
                                       → lock_version も +1 される（Rails 8）
```

この状態で `article.update!({ lock_version: 0 })` を呼ぶと、DB の `lock_version` はすでに上がっているため `StaleObjectError` になる。

**対処パターン：**

```ruby
ActiveRecord::Base.transaction do
  # 1. counter_cache が lock_version を加算する前に楽観的ロックを検証
  client_lock_version = @params[:lock_version]
  if client_lock_version && @article.lock_version != client_lock_version.to_i
    raise ActiveRecord::StaleObjectError.new(@article, "update")
  end

  # 2. 関連操作（ここで counter_cache が lock_version を加算する）
  attach_tags

  # 3. reload して最新の lock_version を取得してから update!
  if update_params.any?
    @article.reload
    @article.update!(update_params)
  end
end
```

ポイント：
- ユーザーが送った `lock_version` の検証はトランザクション**冒頭**で手動チェック
- `attach_tags` 後は必ず `reload` して DB の最新 `lock_version` を取得してから `update!`
- `update!` に `lock_version` を渡さず、`reload` 後のモデルの値をそのまま使う
- サービスは `current_user` が必ず存在する前提で動く。nil チェックは Mutation 層の責務のため、サービス内では行わない
- `composed_of` で VO 管理しているカラムを扱う場合、文字列比較せずに VO のドメインメソッドを使う:
  ```ruby
  # NG
  if @article.status == "published"
  # OK
  if @article.status.published?
  ```

### 外部サービスクライアント（NotificationClient）

notification-service への HTTP 呼び出しを担う `NotificationClient` は上記規約の**対象外**で、別パターンに従う。

- `NotificationClient.notify(...)` クラスメソッド経由で呼び出す（Faraday 製の HTTP クライアント）
- 戻り値は **boolean**（成否）。`Result` オブジェクトは返さない
- `Faraday::Error` を rescue して `false` を返す **non-blocking 設計**。通知の失敗が記事作成をブロックしてはならない
- 接続先は `NOTIFICATION_SERVICE_URL` 環境変数（定数 `NotificationClient::BASE_URL`）、認証は `INTER_SERVICE_SECRET`
- 実際の呼び出しは `ArticleNotificationJob` 経由（非同期）で行い、ビジネスロジックサービスから直接 HTTP を叩かない
- 既存実装の参照: `app/services/notification_client.rb`