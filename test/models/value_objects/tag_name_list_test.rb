require "test_helper"

class ValueObjects::TagNameListTest < ActiveSupport::TestCase
  test "カンマ区切り文字列をパースできる" do
    list = ValueObjects::TagNameList.new("Rails, Ruby, Web")
    assert_equal [ "rails", "ruby", "web" ], list.names
  end

  test "前後の空白を除去する" do
    list = ValueObjects::TagNameList.new("  rails  ,  ruby  ")
    assert_equal [ "rails", "ruby" ], list.names
  end

  test "大文字を小文字に正規化する" do
    list = ValueObjects::TagNameList.new("Rails,RUBY")
    assert_equal [ "rails", "ruby" ], list.names
  end

  test "重複を除去する" do
    list = ValueObjects::TagNameList.new("rails,rails,ruby")
    assert_equal [ "rails", "ruby" ], list.names
  end

  test "空文字列で初期化すると empty? が true" do
    assert ValueObjects::TagNameList.new("").empty?
  end

  test "nil で初期化すると empty? が true" do
    assert ValueObjects::TagNameList.new(nil).empty?
  end

  test "String 以外（Integer）は ArgumentError" do
    assert_raises(ArgumentError) { ValueObjects::TagNameList.new(123) }
  end

  test "freeze されていてイミュータブル" do
    list = ValueObjects::TagNameList.new("rails")
    assert list.frozen?
    assert list.names.frozen?
  end

  test "同じ内容なら == で等しい" do
    a = ValueObjects::TagNameList.new("rails, ruby")
    b = ValueObjects::TagNameList.new("rails, ruby")
    assert_equal a, b
  end

  test "to_s でカンマ区切り文字列を返す" do
    assert_equal "rails, ruby", ValueObjects::TagNameList.new("rails, ruby").to_s
  end
end
