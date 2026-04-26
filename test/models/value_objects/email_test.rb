require "test_helper"

class ValueObjects::EmailTest < ActiveSupport::TestCase
  # ── 初期化 ──────────────────────────────────

  test "小文字化・空白除去して初期化される" do
    email = ValueObjects::Email.new("  User@Example.COM  ")
    assert_equal "user@example.com", email.value
  end

  test "String 以外を渡すと ArgumentError" do
    assert_raises(ArgumentError) { ValueObjects::Email.new(nil) }
    assert_raises(ArgumentError) { ValueObjects::Email.new(123) }
  end

  test "freeze されていてイミュータブル" do
    email = ValueObjects::Email.new("user@example.com")
    assert email.frozen?
  end

  # ── 派生情報 ──────────────────────────────────

  test "domain を返す" do
    assert_equal "example.com", ValueObjects::Email.new("user@example.com").domain
  end

  test "local_part を返す" do
    assert_equal "user", ValueObjects::Email.new("user@example.com").local_part
  end

  # ── 同値性 ──────────────────────────────────

  test "同じアドレスなら == で等しい" do
    a = ValueObjects::Email.new("user@example.com")
    b = ValueObjects::Email.new("user@example.com")
    assert_equal a, b
  end

  test "大文字小文字が違っても == で等しい（正規化後に比較）" do
    a = ValueObjects::Email.new("User@Example.com")
    b = ValueObjects::Email.new("user@example.com")
    assert_equal a, b
  end

  test "異なるアドレスは == で等しくない" do
    a = ValueObjects::Email.new("alice@example.com")
    b = ValueObjects::Email.new("bob@example.com")
    assert_not_equal a, b
  end

  test "Hash のキーとして同値で扱える" do
    h = { ValueObjects::Email.new("user@example.com") => "value" }
    assert_equal "value", h[ValueObjects::Email.new("user@example.com")]
  end

  # ── 変換 ──────────────────────────────────────

  test "to_s で文字列を返す" do
    assert_equal "user@example.com", ValueObjects::Email.new("user@example.com").to_s
  end
end
