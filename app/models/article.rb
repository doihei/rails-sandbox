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
  scope :popular,   -> {
    joins(:comments)
      .group("articles.id")
      .having("COUNT(comments.id) >= 3")
  }
  scope :tagged_with, ->(tag_name) {
    joins(:tags).where(tags: { name: tag_name }).distinct
  }
  scope :tagged_with_all, ->(*tag_names) {
    tag_names.inject(all) do |relation, tag_name|
      relation.where(id: Article.joins(:tags).where(tags: { name: tag_name }).select(:id))
    end
  }
  scope :by_latest_comment, -> {
    left_joins(:comments)
      .group("articles.id")
      .order("MAX(comments.created_at) DESC NULLS LAST")
  }
  scope :above_average_comments, -> {
    where("comments_count > (SELECT AVG(comments_count) FROM articles WHERE comments_count > 0)")
  }

  private

  def normalize_title
    self.title = title.strip
  end

  def set_default_status
    write_attribute(:status, "draft") if read_attribute(:status).blank?
  end
end
