require "rails_helper"

RSpec.describe NotificationClient do
  describe ".notify" do
    context "通知サービスが正常なとき" do
      before do
        stub_request(:post, "#{NotificationClient::BASE_URL}/api/v1/notifications")
          .to_return(status: 201, body: { notification: { id: 1 } }.to_json)
      end

      it "true を返す" do
        expect(
          described_class.notify(article_id: 1, message: "test", user_id: 1)
        ).to be true
      end
    end

    context "通知サービスが落ちているとき" do
      before do
        stub_request(:post, "#{NotificationClient::BASE_URL}/api/v1/notifications")
          .to_raise(Faraday::ConnectionFailed.new("connection refused"))
      end

      it "false を返す（記事作成はブロックしない）" do
        expect(
          described_class.notify(article_id: 1, message: "test", user_id: 1)
        ).to be false
      end
    end
  end
end
