---
paths:
  - "app/models/value_objects/**/*.rb"
  - "test/models/value_objects/**/*.rb"
---

## Value Object の規約

### 概要

ドメインの概念（メールアドレス・金額・座標など）を「同値性で比較するオブジェクト」として表現する。
プリミティブ値をそのまま扱う代わりに Value Object を使うことで、型安全性・正規化・ドメインロジックの集約が得られる。

### ファイル配置

- 実装: `app/models/value_objects/<name>.rb`
- テスト: `test/models/value_objects/<name>_test.rb`
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

### ActiveRecord モデルとの連携

`composed_of` は Rails の uniqueness バリデーションや Devise と互換性の問題が起きるため**使用しない**。
代わりに `_vo` サフィックスのゲッターメソッドを定義し、DB カラムは文字列のまま保持する。

```ruby
class User < ApplicationRecord
  # DB カラム (email: string) はそのまま Rails/Devise に委ねる
  # Value Object への変換は専用メソッドで提供する
  def email_vo
    value = read_attribute(:email)
    value.present? ? ValueObjects::Email.new(value) : nil
  end
end
```

- `user.email` → 文字列（Rails/Devise が使用）
- `user.email_vo` → `ValueObjects::Email`（ドメインロジックで使用）

### テスト

`ActiveSupport::TestCase` を継承し、正常系・異常系・同値性・変換を網羅する。

```ruby
class ValueObjects::EmailTest < ActiveSupport::TestCase
  test "小文字化・空白除去して初期化される" do
    assert_equal "user@example.com", ValueObjects::Email.new("  User@Example.COM  ").value
  end

  test "String 以外を渡すと ArgumentError" do
    assert_raises(ArgumentError) { ValueObjects::Email.new(nil) }
  end

  test "同じアドレスなら == で等しい" do
    assert_equal ValueObjects::Email.new("a@b.com"), ValueObjects::Email.new("a@b.com")
  end
end
```