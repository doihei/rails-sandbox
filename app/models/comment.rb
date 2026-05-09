class Comment < ApplicationRecord
  belongs_to :article, counter_cache: true
  belongs_to :user

  has_many :likes, as: :likeable, dependent: :destroy

  validates :body, presence: true, length: { maximum: 1000 }

  scope :recent, -> { order(created_at: :desc) }
end
