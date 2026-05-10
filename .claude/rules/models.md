---
paths:
  - "app/models/**/*.rb"
  - "test/models/**/*.rb"
---

## モデル規約

### 基本構造

全モデルは `ApplicationRecord` を継承する。Value Object は `app/models/value_objects/` に配置し `ValueObjects` モジュールで囲む（詳細は `value_objects.md` 参照）。

### アソシエーション

#### dependent の指定

親モデル削除時に子レコードも削除する場合は `dependent: :destroy` を設定する：

```ruby
# User
has_many :articles, dependent: :destroy
has_many :comments, dependent: :destroy

# Article
has_many :article_tags, dependent: :destroy
has_many :comments, dependent: :destroy
```

#### ポリモーフィックアソシエーション（被参照側）

複数モデルから参照される場合は `as:` オプションで polymorphic を宣言する：

```ruby
# Article / Comment 共通
has_many :likes, as: :likeable, dependent: :destroy
```

#### counter_cache

関連レコードのカウントを頻繁に参照する場合は `counter_cache: true` を設定する。カラムを読むだけで SQL が発生しない（N+1 防止）：

```ruby
# app/models/comment.rb
belongs_to :article, counter_cache: true
```

マイグレーションでカラムを追加する（デフォルト 0 / NOT NULL）：

```ruby
add_column :articles, :comments_count, :integer, default: 0, null: false
```

#### counter_cache（has_many :through の中間モデル）

多対多（`has_many :through`）の場合は、中間モデルの `belongs_to` にカスタムカラム名で指定する：

```ruby
# app/models/article_tag.rb
class ArticleTag < ApplicationRecord
  belongs_to :article, counter_cache: :tags_count
  belongs_to :tag, counter_cache: :articles_count
end
```

マイグレーションで両テーブルにカラムを追加する：

```ruby
add_column :articles, :tags_count, :integer, default: 0, null: false
add_column :tags, :articles_count, :integer, default: 0, null: false
```

既存データは `reset_counters` でバックフィルする：

```ruby
Tag.find_each { |tag| Tag.reset_counters(tag.id, :article_tags) }
Article.find_each { |article| Article.reset_counters(article.id, :article_tags) }
```

### バリデーション

標準バリデーションは `validates` で記述する。エラーメッセージは i18n で管理し `message:` にハードコードしない（詳細は `i18n.md` 参照）：

```ruby
validates :title, presence: true, length: { maximum: 100 }
validates :body,  presence: true
validates :name,  presence: true, uniqueness: true, length: { maximum: 30 }
validates :tag_id, uniqueness: { scope: :article_id }
```

### コールバック

データの正規化・デフォルト値設定はコールバックで行う：

| タイミング | 用途 |
|---|---|
| `before_validation on: :create` | デフォルト値のセット |
| `before_save` | 文字列の正規化（strip など） |

```ruby
before_validation :set_default_status, on: :create
before_save :normalize_title

private

def normalize_title
  self.title = title.strip
end

def set_default_status
  # composed_of で管理しているカラムは read_attribute / write_attribute を使う
  write_attribute(:status, "draft") if read_attribute(:status).blank?
end
```

### スコープ

#### シンプルなスコープ

```ruby
scope :published, -> { where(status: "published") }
scope :recent,    -> { order(created_at: :desc) }
```

#### パラメータ付きスコープ

ラムダの引数に必ず仮引数を宣言する（省略すると `NameError` になる）：

```ruby
scope :tagged_with, ->(tag_name) {
  joins(:tags).where(tags: { name: tag_name }).distinct
}
```

#### JOIN + GROUP + HAVING（集計絞り込み）

`group` に渡すテーブル名は必ず複数形にする（単数形だと PostgreSQL エラー）：

```ruby
scope :popular, -> {
  joins(:comments)
    .group("articles.id")          # NG: "article.id"
    .having("articles.comments_count >= 3")
    .order("articles.comments_count DESC")
}
```

#### 複数タグ AND 検索（サブクエリパターン）

`joins` を連鎖させると同じ JOIN がデデュープされ `WHERE tags.name = 'a' AND tags.name = 'b'` となり常に空になる。各条件を独立したサブクエリで絞り込む：

```ruby
# NG: JOIN 重複で常に空になる
scope :tagged_with_all, ->(*tag_names) {
  tag_names.inject(all) do |rel, name|
    rel.joins(:tags).where(tags: { name: name })
  end.distinct
}

# OK: where(id: サブクエリ) で AND 絞り込み
scope :tagged_with_all, ->(*tag_names) {
  tag_names.inject(all) do |rel, name|
    rel.where(id: Article.joins(:tags).where(tags: { name: name }).select(:id))
  end
}
```

#### LEFT JOIN + NULLS LAST

関連なしのレコードも含めて並べる場合は `left_joins` を使い、PostgreSQL の `NULLS LAST` で NULL を末尾に置く：

```ruby
scope :by_latest_comment, -> {
  left_joins(:comments)
    .group("articles.id")
    .order("MAX(comments.created_at) DESC NULLS LAST")
}
```

#### counter_cache カラムを使ったサブクエリ比較

`comments_count` などのカウントカラムはそのままサブクエリと比較できる：

```ruby
scope :above_average_comments, -> {
  where("comments_count > (SELECT AVG(comments_count) FROM articles WHERE comments_count > 0)")
}
```

### クラスメソッド

`select` で動的カラムを追加するなど返り値の構造が変わる集計・ランキング系クエリは `scope` ではなくクラスメソッドで定義する：

```ruby
def self.article_count_ranking
  joins(:articles)
    .group("users.id")
    .select("users.*, COUNT(articles.id) AS articles_count")
    .order("articles_count DESC")
end
```

### Value Object との連携

#### composed_of（Devise 非管理カラム）

`composed_of` + `converter` を使うとカラムを VO として直接管理できる。`update!(status: "published")` のような文字列渡しも `converter` 経由で自動変換される：

```ruby
composed_of :status,
            class_name: "ValueObjects::ArticleStatus",
            mapping: [ [ "status", "value" ] ],
            converter: ->(v) { ValueObjects::ArticleStatus.new(v.to_s) }
```

テスト内では文字列と直接比較せず述語メソッドを使う：

```ruby
# NG: composed_of カラムを文字列比較しない
assert_equal "published", article.status
# OK
assert article.status.published?
```

`composed_of` で管理しているカラムをコールバック内で読み書きする場合は `read_attribute` / `write_attribute` を使う（VO を経由しないため）。

#### _vo メソッド（Devise 管理カラム）

`email` など Devise が直接操作するカラムは `composed_of` を使わず `_vo` サフィックスのゲッターメソッドで VO を提供する：

```ruby
def email_vo
  value = read_attribute(:email)
  value.present? ? ValueObjects::Email.new(value) : nil
end
```

### 楽観的ロック（Optimistic Locking）

同時編集による競合を防ぐ場合は `lock_version` カラムで楽観的ロックを有効にする。カラム名は明示的に指定する：

```ruby
self.locking_column = :lock_version
```

マイグレーションでカラムを追加する（デフォルト 0 / NOT NULL）：

```ruby
add_column :articles, :lock_version, :integer, default: 0, null: false
```

フォームの `hidden_field` で `lock_version` を送信し、コントローラの Strong Parameters に含める。
競合時（`StaleObjectError`）のハンドリングは `ApplicationController` の `rescue_from` で一元管理する（詳細は `controllers.md` 参照）。

### Tag の正規化

タグ名の検索・作成は `Tag.find_or_create_by_name!` を通じて行う。このメソッドが小文字化・前後空白除去を一元管理する：

```ruby
def self.find_or_create_by_name!(name)
  find_or_create_by!(name: name.strip.downcase)
end
```

直接 `Tag.find_or_create_by(name: ...)` を呼ばず、必ずこのメソッドを使う。
