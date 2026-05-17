require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "バリデーション" do
    it "name があれば有効" do
      tag = build(:tag)
      expect(tag).to be_valid
    end

    it "name が空なら無効" do
      tag = build(:tag, name: "")
      expect(tag).not_to be_valid
    end

    it "name が重複すると無効" do
      create(:tag, name: "ruby")
      tag = build(:tag, name: "ruby")
      expect(tag).not_to be_valid
    end
  end

  describe "アソシエーション" do
    it "has_many :through で記事と関連付けられる" do
      tag = create(:tag)
      article = create(:article)
      article.tags << tag
      expect(tag.articles).to include(article)
    end

    it "タグ削除時に記事は残る" do
      tag = create(:tag)
      article = create(:article)
      article.tags << tag
      tag.destroy
      expect(Article.exists?(article.id)).to be true
    end
  end
end
