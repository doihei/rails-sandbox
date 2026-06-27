class Like < ApplicationRecord
  belongs_to :likeable, polymorphic: true
  belongs_to :user

  counter_culture :likeable, column_name: "likes_count"

  validates :user_id, uniqueness: { scope: [ :likeable_type, :likeable_id ] }
end
