class Article < ApplicationRecord
  belongs_to :user

  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags
  has_many :comments, dependent: :destroy

  composed_of :status,
              class_name: "ValueObjects::ArticleStatus",
              mapping: [ [ "status", "value" ] ],
              converter: ->(v) { ValueObjects::ArticleStatus.new(v.to_s) }

  validates :title, presence: true, length: { maximum: 100 }
  validates :body,  presence: true

  before_validation :set_default_status, on: :create
  before_save :normalize_title

  scope :published, -> { where(status: "published") }
  scope :recent,    -> { order(created_at: :desc) }

  private

  def normalize_title
    self.title = title.strip
  end

  def set_default_status
    write_attribute(:status, "draft") if read_attribute(:status).blank?
  end
end
