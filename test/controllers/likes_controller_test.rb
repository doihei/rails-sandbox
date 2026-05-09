require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user    = users(:one)
    @article = articles(:one)
    @comment = comments(:one)
    sign_in @user
  end

  test "記事にいいねするとcreatedフラッシュでリダイレクト" do
    post likes_url, params: { likeable_type: "Article", likeable_id: @article.id }
    assert_redirected_to root_path
    assert_equal I18n.t("flash.like.created"), flash[:notice]
  end

  test "いいね済みの記事をトグルするとdestroyedフラッシュでリダイレクト" do
    Like.create!(user: @user, likeable: @article)
    post likes_url, params: { likeable_type: "Article", likeable_id: @article.id }
    assert_redirected_to root_path
    assert_equal I18n.t("flash.like.destroyed"), flash[:notice]
  end

  test "コメントにいいねできる" do
    post likes_url, params: { likeable_type: "Comment", likeable_id: @comment.id }
    assert_redirected_to root_path
    assert_equal I18n.t("flash.like.created"), flash[:notice]
  end

  test "不正な likeable_type は 400 Bad Request" do
    post likes_url, params: { likeable_type: "User", likeable_id: @user.id }
    assert_response :bad_request
  end

  test "存在しない likeable_id は 404" do
    post likes_url, params: { likeable_type: "Article", likeable_id: 999999999 }
    assert_response :not_found
  end

  test "未ログインはログイン画面へリダイレクト" do
    sign_out :user
    post likes_url, params: { likeable_type: "Article", likeable_id: @article.id }
    assert_redirected_to new_user_session_path
  end
end
