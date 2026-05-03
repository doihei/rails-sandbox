class Tag < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  validates :name, presence: true, uniqueness: true, length: { maximum: 30 }

  # 見つからなければ作る — コントローラで使う
  def self.find_or_create_by_name!(name)
    find_or_create_by!(name: name.strip.downcase)
  end
end
