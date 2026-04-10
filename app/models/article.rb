class Article < ApplicationRecord
  STATUSES = %w[draft published archived].freeze

  validates :title, presence: true, length: { maximum: 100 }
  validates :body,  presence: true
  validates :status, inclusion: { in: STATUSES }

  before_save :normalize_title
  before_create :set_default_status

  scope :published, -> { where(status: "published") }
  scope :recent,    -> { order(created_at: :desc) }

  private

  def normalize_title
    self.title = title.strip
  end

  def set_default_status
    self.status ||= "draft"
  end
end
