require "test_helper"

class Likes::ToggleServiceTest < ActiveSupport::TestCase
  setup do
    @user    = users(:one)
    @article = articles(:one)
  end

  test "未いいねの記事にいいねするとliked: trueで返る" do
    result = Likes::ToggleService.call(user: @user, likeable: @article)
    assert result.success?
    assert result.value[:liked]
    assert_equal 1, result.value[:count]
  end

  test "いいね済みの記事をトグルするとliked: falseで返る" do
    Like.create!(user: @user, likeable: @article)
    result = Likes::ToggleService.call(user: @user, likeable: @article)
    assert result.success?
    assert_not result.value[:liked]
    assert_equal 0, result.value[:count]
  end

  test "コメントにもいいねできる" do
    result = Likes::ToggleService.call(user: @user, likeable: comments(:one))
    assert result.success?
    assert result.value[:liked]
  end
end
