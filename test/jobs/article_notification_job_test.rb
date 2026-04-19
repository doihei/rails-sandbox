require "test_helper"

class ArticleNotificationJobTest < ActiveJob::TestCase
  setup do
    @user = users(:one)
    @article = articles(:one)
  end

  # performが正常に実行されることを確認
  test "perform succeeds" do
    assert_nothing_raised do
      ArticleNotificationJob.new.perform(@article)
    end
  end

  # perform_laterでキューに積まれることを確認
  test "enqueues on article create" do
    assert_enqueued_with(job: ArticleNotificationJob) do
      ArticleNotificationJob.perform_later(@article)
    end
  end

  # 実際に実行されることを確認
  test "performs enqueued jobs" do
    perform_enqueued_jobs do
      ArticleNotificationJob.perform_later(@article)
    end
  end
end
