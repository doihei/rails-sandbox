require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def valid_comment
    Comment.new(
      body:    "テストコメント",
      article: articles(:one),
      user:    users(:one)
    )
  end

  test "有効なコメントは保存できる" do
    assert valid_comment.valid?
  end

  test "本文なしは無効" do
    assert_not valid_comment.tap { |c| c.body = "" }.valid?
  end

  test "1001文字以上は無効" do
    assert_not valid_comment.tap { |c| c.body = "a" * 1001 }.valid?
  end

  test "記事を削除するとコメントも削除される" do
    article = articles(:one)
    count   = article.comments.count
    assert_difference "Comment.count", -count do
      article.destroy
    end
  end

  test "recent スコープは新しい順に返す" do
    comments = articles(:one).comments.recent
    assert comments.first.created_at >= comments.last.created_at
  end
end
