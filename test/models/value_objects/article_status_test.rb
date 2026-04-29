require "test_helper"

class ValueObjects::ArticleStatusTest < ActiveSupport::TestCase
  test "有効なステータスで初期化できる" do
    %w[draft published archived].each do |s|
      assert_nothing_raised { ValueObjects::ArticleStatus.new(s) }
    end
  end

  test "不正なステータスは ArgumentError" do
    assert_raises(ArgumentError) { ValueObjects::ArticleStatus.new("invalid") }
    assert_raises(ArgumentError) { ValueObjects::ArticleStatus.new("") }
  end

  test "freeze されてイミュータブル" do
    assert ValueObjects::ArticleStatus.new("draft").frozen?
  end

  test "draft? / published? / archived? が正しく返る" do
    assert ValueObjects::ArticleStatus.new("draft").draft?
    assert ValueObjects::ArticleStatus.new("published").published?
    assert ValueObjects::ArticleStatus.new("archived").archived?
  end

  test "publishable? は draft のみ true" do
    assert     ValueObjects::ArticleStatus.new("draft").publishable?
    assert_not ValueObjects::ArticleStatus.new("published").publishable?
    assert_not ValueObjects::ArticleStatus.new("archived").publishable?
  end

  test "archivable? は published のみ true" do
    assert     ValueObjects::ArticleStatus.new("published").archivable?
    assert_not ValueObjects::ArticleStatus.new("draft").archivable?
  end

  test "同値性 == が正しく動く" do
    assert_equal ValueObjects::ArticleStatus.new("draft"),
                 ValueObjects::ArticleStatus.new("draft")
    assert_not_equal ValueObjects::ArticleStatus.new("draft"),
                     ValueObjects::ArticleStatus.new("published")
  end

  test "article.status は ArticleStatus オブジェクトを返す" do
    assert_instance_of ValueObjects::ArticleStatus, articles(:one).status
  end

  test "article.status.draft? が true" do
    assert articles(:one).status.draft?   # fixtures: status: draft
  end
end
