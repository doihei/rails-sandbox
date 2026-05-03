require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
    sign_in users(:one)
  end

  test "コメントを投稿できる" do
    assert_difference "Comment.count" do
      post article_comments_url(@article),
           params: { comment: { body: "新しいコメント" } }
    end
    assert_redirected_to article_url(@article)
  end

  test "本文なしは投稿できない" do
    assert_no_difference "Comment.count" do
      post article_comments_url(@article),
           params: { comment: { body: "" } }
    end
    assert_redirected_to article_url(@article)
  end

  test "自分のコメントを削除できる" do
    comment = comments(:one)
    assert_difference "Comment.count", -1 do
      delete article_comment_url(@article, comment)
    end
    assert_redirected_to article_url(@article)
  end

  test "他人のコメントは削除できない" do
    sign_out :user
    sign_in users(:two)
    comment = comments(:one)  # user: one のコメント
    assert_no_difference "Comment.count" do
      delete article_comment_url(@article, comment)
    end
    assert_redirected_to article_url(@article)
    assert_equal I18n.t("flash.comment.unauthorized"), flash[:alert]
  end
end
