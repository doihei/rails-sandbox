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

  def find_likeable
    # params[:likeable_type] = "Article" or "Comment"
    # params[:likeable_id]   = 対象のID
    klass = params[:likeable_type].safe_constantize
    raise ActionController::BadRequest unless klass&.in?([ Article, Comment ])
    klass.find(params[:likeable_id])
  end
end
