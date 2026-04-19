require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_user
    name = "test_#{SecureRandom.hex(4)}"
    User.new(
      name: name,
      email: name + "@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "有効なユーザーは保存できる" do
    assert valid_user.valid?
  end

  test "emailがなければ無効" do
    user = valid_user.tap { |u| u.email = "" }
    assert_not user.valid?
  end

  test "パスワードが6文字未満なら無効" do
    user = valid_user.tap { |u| u.password = "abc" }
    assert_not user.valid?
  end

  test "emailの重複は無効" do
    existing = users(:one)
    user = valid_user.tap { |u| u.email = existing.email }
    assert_not user.valid?
  end

  test "has_many articles" do
    user = users(:one)
    assert_respond_to user, :articles
    assert_instance_of Article, user.articles.first
  end

  test "ユーザー削除で記事も削除される" do
    user = users(:one)
    count = user.articles.count
    assert_difference "Article.count", -count do
      user.destroy
    end
  end

  test "valid_password? でBCrypt照合できる" do
    user = users(:one)
    assert user.valid_password?("password")
    assert_not user.valid_password?("wrong")
  end
end
