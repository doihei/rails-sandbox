require "test_helper"

class LikeTest < ActiveSupport::TestCase
  test "記事にいいねできる" do
    like = Like.new(user: users(:one), likeable: articles(:one))
    assert like.valid?
  end

  test "コメントにいいねできる" do
    like = Like.new(user: users(:one), likeable: comments(:one))
    assert like.valid?
  end

  test "同じユーザーが同じ記事に2回いいねできない" do
    Like.create!(user: users(:one), likeable: articles(:one))
    dup = Like.new(user: users(:one), likeable: articles(:one))
    assert_not dup.valid?
  end

  test "異なるユーザーは同じ記事にいいねできる" do
    Like.create!(user: users(:one), likeable: articles(:one))
    like2 = Like.new(user: users(:two), likeable: articles(:one))
    assert like2.valid?
  end

  test "記事を削除するといいねも削除される" do
    Like.create!(user: users(:one), likeable: articles(:one))
    assert_difference "Like.count", -1 do
      articles(:one).destroy
    end
  end
end
