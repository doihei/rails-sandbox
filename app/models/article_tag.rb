class ArticleTag < ApplicationRecord
  belongs_to :article, counter_cache: :tags_count
  belongs_to :tag, counter_cache: :articles_count

  validates :tag_id, uniqueness: { scope: :article_id }
end
