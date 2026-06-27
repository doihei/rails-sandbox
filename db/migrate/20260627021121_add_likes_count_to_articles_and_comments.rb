class AddLikesCountToArticlesAndComments < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :likes_count, :integer, default: 0, null: false
    add_column :comments, :likes_count, :integer, default: 0, null: false
  end
end
