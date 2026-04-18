class AddIndexToArticlesOnStatusAndCreatedAt < ActiveRecord::Migration[8.1]
  def change
    add_index :articles, [ :status, :created_at ]
  end
end
