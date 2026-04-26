require "test_helper"

class Articles::CreateServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  # ── 正常系 ──────────────────────────────────

  test "有効なパラメータで記事を作成できる" do
    result = Articles::CreateService.call(
      user:   @user,
      params: { title: "新しい記事", body: "本文" }
    )
    assert result.success?
    assert_equal "新しい記事", result.value.title
    assert_equal "draft", result.value.status
  end

  test "作成後にJobがキューに積まれる" do
    assert_enqueued_with(job: ArticleNotificationJob) do
      Articles::CreateService.call(
        user:   @user,
        params: { title: "新しい記事", body: "本文" }
      )
    end
  end

  test "Article.countが1増える" do
    assert_difference "Article.count", 1 do
      Articles::CreateService.call(
        user:   @user,
        params: { title: "新しい記事", body: "本文" }
      )
    end
  end

  # ── 異常系 ──────────────────────────────────

  test "タイトルなしはfailure" do
    result = Articles::CreateService.call(
      user:   @user,
      params: { title: "", body: "本文" }
    )
    assert result.failure?
    assert_includes result.error, "Title"
  end

  test "本文なしはfailure" do
    result = Articles::CreateService.call(
      user:   @user,
      params: { title: "タイトル", body: "" }
    )
    assert result.failure?
    assert_includes result.error, "Body"
  end
end
