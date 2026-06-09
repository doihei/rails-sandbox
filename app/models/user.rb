class User < ApplicationRecord
  has_secure_password

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :password, length: { minimum: 6 }, allow_nil: true

  attribute :email, AttributeTypes::EmailType.new

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.article_count_ranking
    joins(:articles)
      .group("users.id")
      .select("users.*, COUNT(articles.id) AS articles_count")
      .order("articles_count DESC")
  end
end
