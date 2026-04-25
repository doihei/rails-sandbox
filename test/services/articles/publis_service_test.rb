require "test_helper"

class Articles::PublishServiceTest < ActiveSupport::TestCase
  setup do
    @owner   = users(:one)
    @article = articles(:one)   # status: "draft"
  end

  # ── 正常系 ──────────────────────────────────

  test "draft記事を所有者が公開するとsuccess" do
    result = Articles::PublishService.call(
      article:      @article,
      current_user: @owner
    )
    assert result.success?
    assert_equal "published", result.value.status
  end

  test "Jobがキューに積まれる" do
    assert_enqueued_with(job: ArticleNotificationJob) do
      Articles::PublishService.call(
        article:      @article,
        current_user: @owner
      )
    end
  end

  # ── 異常系 ──────────────────────────────────

  test "他人の記事はfailure" do
    other = users(:two)
    result = Articles::PublishService.call(
      article:      @article,
      current_user: other
    )
    assert result.failure?
    assert_includes result.error, "権限がありません"
  end

  test "published済みはfailure" do
    @article.update!(status: "published")
    result = Articles::PublishService.call(
      article:      @article,
      current_user: @owner
    )
    assert result.failure?
    assert_includes result.error, "すでに公開済み"
  end

  test "archived記事はfailure" do
    @article.update!(status: "archived")
    result = Articles::PublishService.call(
      article:      @article,
      current_user: @owner
    )
    assert result.failure?
    assert_includes result.error, "アーカイブ済み"
  end
end
