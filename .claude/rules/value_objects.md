---
paths:
  - "app/models/value_objects/**/*.rb"
  - "spec/models/value_objects/**/*.rb"
  - "app/models/*.rb"
---

## Value Object の規約

### 概要

ドメインの概念（メールアドレス・金額・座標など）を「同値性で比較するオブジェクト」として表現する。
プリミティブ値をそのまま扱う代わりに Value Object を使うことで、型安全性・正規化・ドメインロジックの集約が得られる。

### ファイル配置

- 実装: `app/models/value_objects/<name>.rb`
- テスト: `spec/models/value_objects/<name>_spec.rb`
- ネームスペース: `ValueObjects` モジュールで囲む

```ruby
# app/models/value_objects/email.rb
module ValueObjects
  class Email
    ...
  end
end
```

### 実装パターン

```ruby
module ValueObjects
  class Email
    attr_reader :value

    def initialize(value)
      raise ArgumentError, "String である必要があります" unless value.is_a?(String)
      @value = value.downcase.strip
      freeze  # イミュータブルにする
    end

    # 同値性（== / eql? / Hash キー対応）
    def ==(other)
      other.is_a?(Email) && other.value == value
    end
    alias eql? ==

    def hash
      value.hash
    end

    def to_s
      @value
    end
  end
end
```

### コレクション型 Value Object

複数の値をまとめて正規化・管理する場合は、コレクション型 VO として実装する。
単一値の `value` ではなく `names` などの配列属性を持ち、`empty?` で空判定する。

```ruby
module ValueObjects
  class TagNameList
    attr_reader :names

    def initialize(raw)
      raise ArgumentError, "String または nil を渡してください" unless raw.nil? || raw.is_a?(String)
      @names = raw.to_s.split(",").map { |n| n.strip.downcase }.reject(&:blank?).uniq.freeze
      freeze
    end

    def empty?
      @names.empty?
    end

    def ==(other)
      other.is_a?(TagNameList) && other.names == names
    end
    alias eql? ==

    def hash
      names.hash
    end
  end
end
```

使用例：

```ruby
tag_list = ValueObjects::TagNameList.new("Rails, ruby, RAILS")
tag_list.names  # => ["rails", "ruby"]
tag_list.empty? # => false
```

### ActiveRecord モデルとの連携

AR カラムを VO として管理するには 2 通りある。どちらを使うかはバリデーションの有無で判断する。

#### `composed_of`（uniqueness バリデーションがないカラム）

`composed_of` + `converter` を使う。`update!(status: "published")` のような文字列渡しも自動変換される。

```ruby
class Article < ApplicationRecord
  composed_of :status,
              class_name: "ValueObjects::ArticleStatus",
              mapping: [ [ "status", "value" ] ],
              converter: ->(v) { ValueObjects::ArticleStatus.new(v.to_s) }
end
```

#### カスタム属性型（uniqueness バリデーションがあるカラム）

`uniqueness` バリデーションを持つカラムは `composed_of` を使うと AR のクエリシステムが VO を SQL 値に変換できず TypeError になる。
`cast` / `serialize` を実装したカスタム型を `app/models/attribute_types/` に置き、`attribute` で登録する。

```ruby
# app/models/attribute_types/email_type.rb
module AttributeTypes
  class EmailType < ActiveRecord::Type::String
    def cast(value)
      return nil if value.blank?
      value.is_a?(ValueObjects::Email) ? value : ValueObjects::Email.new(value.to_s)
    end

    def serialize(value)
      return nil if value.nil?
      value.is_a?(ValueObjects::Email) ? value.value : super
    end
  end
end

# app/models/user.rb
class User < ApplicationRecord
  attribute :email, AttributeTypes::EmailType.new
end
```

- `user.email` → `ValueObjects::Email`（VO のドメインメソッドが使える）
- `user.email = "FOO@EXAMPLE.COM"` → cast 経由で正規化済み VO に自動変換
- JSON 比較など文字列が必要な場面では `user.email.to_s` を使う

### テスト

`RSpec.describe` で記述し、正常系・異常系・同値性・変換を網羅する。

```ruby
RSpec.describe ValueObjects::Email, type: :model do
  it "小文字化・空白除去して初期化される" do
    expect(described_class.new("  User@Example.COM  ").value).to eq("user@example.com")
  end

  it "String 以外を渡すと ArgumentError" do
    expect { described_class.new(nil) }.to raise_error(ArgumentError)
  end

  it "同じアドレスなら == で等しい" do
    expect(described_class.new("a@b.com")).to eq(described_class.new("a@b.com"))
  end
end
```