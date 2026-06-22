require "rails_helper"

RSpec.describe ArticleNotificationJob, type: :job do
  let(:article) { create(:article) }

  before do
    stub_request(:post, "#{NotificationClient::BASE_URL}/api/v1/notifications")
      .to_return(status: 201, body: { notification: { id: 1 } }.to_json)
  end

  describe "#perform" do
    it "例外を上げない" do
      expect { described_class.new.perform(article) }.not_to raise_error
    end
  end

  describe ".perform_later" do
    it "キューにジョブが積まれる" do
      expect { described_class.perform_later(article) }
        .to have_enqueued_job(described_class).with(article)
    end
  end

  describe "perform_enqueued_jobs" do
    it "キューを消化してもエラーにならない" do
      described_class.perform_later(article)
      expect { perform_enqueued_jobs }.not_to raise_error
    end
  end
end
