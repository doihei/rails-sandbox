class TagBadgeComponent < ViewComponent::Base
  def initialize(tag:)
    @tag = tag
  end

  def tag_name
    @tag.name
  end

  def path
    Rails.application.routes.url_helpers.tag_articles_path(@tag)
  end
end

