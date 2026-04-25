---
paths:
  - "app/services/**/*.rb"
  - "test/services/**/*.rb"
---

## Service Object の規約

- `ApplicationService` を継承する
- `call` クラスメソッド経由で呼び出す（`ApplicationService.call(...)` が `new(...).call` を委譲）:
  ```ruby
  result = Articles::PublishService.call(article: @article, current_user: current_user)
  ```
- 戻り値は必ず `Result` オブジェクトを返す:
  - 成功: `Result.success(value)`
  - 失敗: `Result.failure("エラーメッセージ")`
- ビジネスロジック固有の例外はサービス内部でクラス定義して rescue する:
  ```ruby
  OwnershipError = Class.new(StandardError)
  ```
- ネームスペースはリソース名の複数形モジュールに統一する（例: `Articles::PublishService`）
- ファイル配置: `app/services/<namespace>/<action>_service.rb`
- 既存実装の参照: `app/services/articles/publish_service.rb`