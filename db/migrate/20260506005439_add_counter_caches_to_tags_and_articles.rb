class AddCounterCachesToTagsAndArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :tags, :articles_count, :integer, default: 0, null: false
    add_column :articles, :tags_count, :integer, default: 0, null: false
  end
end
