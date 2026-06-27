module Mutations
  class ToggleLike < Mutations::AuthenticatedMutation
    argument :likeable_id,   ID,     required: true
    argument :likeable_type, String, required: true

    field :liked,       Boolean,  null: true
    field :likes_count, Integer,  null: true
    field :errors,      [ String ], null: false

    def resolve(likeable_id:, likeable_type:)
      result = Likes::ToggleService.call(
        user:          current_user,
        likeable_id:   likeable_id,
        likeable_type: likeable_type
      )

      if result.success?
        { liked: result.value[:liked], likes_count: result.value[:count], errors: [] }
      else
        { liked: false, likes_count: 0, errors: [ result.error ] }
      end
    end
  end
end
