class NotificationClient
  BASE_URL = ENV.fetch("NOTIFICATION_SERVICE_URL", "http://localhost:3001")
  SECRET   = ENV.fetch("INTER_SERVICE_SECRET", "dev-secret")

  def self.notify(article_id:, message:, user_id:)
    new.notify(article_id: article_id, message: message, user_id: user_id)
  end

  def notify(article_id:, message:, user_id:)
    response = connection.post("api/v1/notifications") do |req|
      req.body = {
        article_id: article_id,
        message: message,
        user_id: user_id
      }.to_json
    end

    response.success?

  rescue Faraday::Error => e
    # 通知失敗は記事作成をブロックしない（non-blocking）
    Rails.logger.error("[NotificationClient] Failed: #{e.message}")
    false
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |f|
      f.request  :json
      f.response :json
      f.headers["Authorization"] = "Bearer #{SECRET}"
      f.adapter Faraday.default_adapter
    end
  end
end
