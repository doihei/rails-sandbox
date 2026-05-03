class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    # タグ名の重複を防ぐ
    add_index :tags, :name, unique: true
  end
end
