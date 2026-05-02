class StatusBadgeComponent < ViewComponent::Base
  def initialize(status:)
    @status = status
  end

  def badge_class
    case @status.value
    when "published" then "bg-green-100 text-green-700"
    when "draft"     then "bg-gray-100 text-gray-600"
    when "archived"  then "bg-orange-100 text-orange-700"
    end
  end

  def label
    I18n.t("article_status.#{@status.value}")
  end
end
