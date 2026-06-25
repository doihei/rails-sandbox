module Types
  class TagType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :articles_count, Integer, null: false
  end
end
