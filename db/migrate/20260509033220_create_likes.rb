class CreateLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :likes do |t|
      t.references :likeable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # 同じユーザーが同じ対象に2回いいねできないようにする
    add_index :likes, [ :user_id, :likeable_type, :likeable_id ], unique: true
  end
end
