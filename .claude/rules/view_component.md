---
paths:
  - "app/components/**/*.rb"
  - "app/components/**/*.html.erb"
  - "app/views/**/*.erb"
  - "test/components/**/*.rb"
---

## ViewComponent 規約

このプロジェクトは `view_component` gem を使用する。再利用性の高い UI 部品はパーシャルではなくコンポーネントで実装する。

### ディレクトリ構成

```
app/components/
  status_badge_component.rb         # 汎用コンポーネント（名前空間なし）
  status_badge_component.html.erb
  tag_badge_component.rb
  tag_badge_component.html.erb
  articles/
    card_component.rb               # articles 専用コンポーネント
    card_component.html.erb

test/components/
  status_badge_component_test.rb
  tag_badge_component_test.rb
  articles/
    card_component_test.rb
```

### 命名規則

- クラス名は `<名前空間>::<名前>Component`（例: `Articles::CardComponent`）
- 汎用部品は名前空間なし（例: `StatusBadgeComponent`）
- ファイル名はスネークケース（例: `card_component.rb`）

### 実装パターン

```ruby
# app/components/articles/card_component.rb
class Articles::CardComponent < ViewComponent::Base
  def initialize(article:)
    @article = article
  end

  # ロジックはメソッドとして定義し、テンプレートから呼び出す
  def author_name
    @article.user.name.presence || @article.user.email
  end
end
```

```erb
<%# app/components/articles/card_component.html.erb %>
<div id="<%= dom_id(@article) %>" class="...">
  <%= author_name %>
</div>
```

### View から render する

```erb
<%# パーシャルではなく render() メソッドにインスタンスを渡す %>
<%= render(Articles::CardComponent.new(article: article)) %>
<%= render(StatusBadgeComponent.new(status: @article.status)) %>
```

### i18n の使い方

コンポーネントの Ruby ファイル（`.rb`）内では `t()` ヘルパーは使えない。`I18n.t()` を使う：

```ruby
def label
  I18n.t("article_status.#{@status.value}")
end
```

テンプレート（`.html.erb`）内では通常の `t()` が使える。

### DOM ID の付け方

Turbo Stream などで DOM を操作する可能性があるリスト要素には `dom_id` を付ける：

```erb
<div id="<%= dom_id(@article) %>">
```

### ルーティングヘルパーの使い方

コンポーネントの Ruby ファイル（`.rb`）内では `_path` / `_url` ヘルパーは直接使えない。
`Rails.application.routes.url_helpers` 経由で呼び出す：

```ruby
def path
  Rails.application.routes.url_helpers.tag_path(@tag)
end
```

### テスト

`ViewComponent::TestCase` を継承する：

```ruby
class Articles::CardComponentTest < ViewComponent::TestCase
  setup do
    @article = articles(:one)
  end

  test "タイトルが描画される" do
    render_inline(Articles::CardComponent.new(article: @article))
    assert_selector "a", text: @article.title
  end
end
```

### アソシエーションのカウントと N+1 対策

コンポーネントで関連レコードの件数を表示する場合、`counter_cache` を使う。
アソシエーションに直接 `.size` / `.count` を呼ぶと一覧表示で N+1 が発生する：

```ruby
# NG: 記事ごとに SQL が発行される
def comment_count
  @article.comments.size
end
```

`counter_cache: true` を設定してカウントカラムを参照する：

```ruby
# app/models/comment.rb
belongs_to :article, counter_cache: true
```

```ruby
# OK: articles.comments_count カラムを読むだけ（SQL 0 回）
def comments_count
  @article.comments_count
end
```

### パーシャルとの使い分け

| 用途 | 選択 |
|---|---|
| ロジックを持つ再利用部品（バッジ・カード等） | ViewComponent |
| 単純な HTML の切り出し・レイアウト補助 | パーシャル |
| フォーム（`form_with` を使う） | パーシャル |