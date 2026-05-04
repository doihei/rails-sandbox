class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # email カラムは文字列のまま Rails/Devise/バリデーションに委ねる
  # Value Object へのアクセスは email_vo メソッドで提供する
  def email_vo
    value = read_attribute(:email)
    value.present? ? ValueObjects::Email.new(value) : nil
  end

  def self.article_count_ranking
    joins(:articles)
      .group("users.id")
      .select("users.*, COUNT(articles.id) AS articles_count")
      .order("articles_count DESC")
  end
end
