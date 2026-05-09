class LikesController < ApplicationController
  def create
    result = Likes::ToggleService.call(
      user: current_user,
      likeable: find_likeable
    )

    if result.success?
      redirect_back fallback_location: root_path,
                    notice: result.value[:liked] ? t("flash.like.created") : t("flash.like.destroyed")
    else
      redirect_back fallback_location: root_path, alert: result.error
    end
  end

  private

  LIKEABLE_TYPES = { "Article" => Article, "Comment" => Comment }.freeze

  def find_likeable
    klass = LIKEABLE_TYPES[params[:likeable_type]]
    raise ActionController::BadRequest unless klass
    klass.find(params[:likeable_id])
  end
end
