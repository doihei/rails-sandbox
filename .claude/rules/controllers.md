---
paths:
  - "app/controllers/**/*.rb"
  - "test/controllers/**/*"
---

## コントローラ規約

### 認証

`ApplicationController` で `before_action :authenticate_user!` を設定済み。全コントローラでデフォルト認証が必要。特定アクションを除外する場合は `skip_before_action` を使う。

### before_action による共通セットアップ

複数アクションで共通のリソース取得は `before_action` + `set_<model>` にまとめる。N+1 対策の `includes` もここで指定する：

```ruby
before_action :set_article, only: %i[show edit update destroy publish]

def set_article
  @article = Article.includes(:user, :tags, comments: :user).find(params.expect(:id))
end
```

### Strong Parameters

Rails 8 の `params.expect` 構文を使う（`params.require.permit` は使わない）：

```ruby
def article_params
  params.expect(article: [:title, :body, :status])
end

# ネストされたリソース
def comment_params
  params.expect(comment: [:body])
end
```

### Service Object への委譲

複雑なビジネスロジックはコントローラに書かず Service Object に委譲する。Service Object は `result.success?` / `result.value` / `result.error` を返す：

```ruby
result = Articles::CreateService.call(user: current_user, params: article_params, ...)

if result.success?
  redirect_to result.value, notice: t("flash.article.created")
else
  @article.errors.add(:base, result.error)
  render :new, status: :unprocessable_entity
end
```

### Flash メッセージ

flash の文言は必ず i18n キーで参照する（ハードコード禁止）：

```ruby
redirect_to @article, notice: t("flash.article.created")
redirect_to @article, alert: t("flash.comment.unauthorized")
```

### PATCH / DELETE 後のリダイレクト

PATCH / DELETE 後の `redirect_to` には `status: :see_other`（HTTP 303）を付ける。ブラウザが戻る操作で非 GET リクエストを再送するのを防ぐため：

```ruby
redirect_to articles_path, notice: t("flash.article.deleted"), status: :see_other
```

### エラーハンドリング

`rescue_from` は個別コントローラに書かず `ApplicationController` で集約する。`ActiveRecord::RecordNotFound` は定義済みのため、個別コントローラで `rescue` する必要はない：

```ruby
# ApplicationController に定義済み
rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
```