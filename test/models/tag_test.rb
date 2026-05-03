require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "有効な名前で作成できる" do
    tag = Tag.new(name: "elixir")
    assert tag.valid?
  end

  test "名前なしは無効" do
    assert_not Tag.new(name: "").valid?
  end

  test "名前の重複は無効" do
    Tag.create!(name: "ActiveRecord")
    assert_not Tag.new(name: "ActiveRecord").valid?
  end

  test "article に tag を追加できる" do
    article = articles(:one)
    tag     = tags(:rails)
    article.tags << tag unless article.tags.include?(tag)
    assert_includes article.tags, tag
  end

  test "article を通じて tag を削除しても tag 本体は残る" do
    article = articles(:one)
    tag     = tags(:rails)
    article.tags << tag unless article.tags.include?(tag)
    article.tags.destroy(tag)
    assert Tag.exists?(tag.id)
  end
end
