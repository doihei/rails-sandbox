---
paths:
  - "app/services/**/*.rb"
  - "spec/services/**/*.rb"
---

## Service Object の規約

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
- 既存実装の参照: `app/services/articles/publish_service.rb`（公開フロー）、`app/services/articles/update_service.rb`（オーナーチェック + 楽観的ロック）
- サービスは `current_user` が必ず存在する前提で動く。nil チェックは Mutation 層の責務のため、サービス内では行わない
- `composed_of` で VO 管理しているカラムを扱う場合、文字列比較せずに VO のドメインメソッドを使う:
  ```ruby
  # NG
  if @article.status == "published"
  # OK
  if @article.status.published?
  ```