require "rails_helper"

RSpec.describe ValueObjects::ArticleStatus, type: :model do
  describe "初期化" do
    it "有効値 draft で初期化できる" do
      expect { described_class.new("draft") }.not_to raise_error
    end

    it "有効値 published で初期化できる" do
      expect { described_class.new("published") }.not_to raise_error
    end

    it "有効値 archived で初期化できる" do
      expect { described_class.new("archived") }.not_to raise_error
    end

    it "不正値で ArgumentError が発生する" do
      expect { described_class.new("invalid") }.to raise_error(ArgumentError)
    end

    it "イミュータブル（frozen）である" do
      expect(described_class.new("draft")).to be_frozen
    end
  end

  describe "述語メソッド" do
    it "draft? が正しく返る" do
      expect(described_class.new("draft").draft?).to be true
      expect(described_class.new("published").draft?).to be false
    end

    it "published? が正しく返る" do
      expect(described_class.new("published").published?).to be true
      expect(described_class.new("draft").published?).to be false
    end

    it "archived? が正しく返る" do
      expect(described_class.new("archived").archived?).to be true
      expect(described_class.new("draft").archived?).to be false
    end

    it "publishable? は draft のみ true" do
      expect(described_class.new("draft").publishable?).to be true
      expect(described_class.new("published").publishable?).to be false
      expect(described_class.new("archived").publishable?).to be false
    end

    it "archivable? は published のみ true" do
      expect(described_class.new("published").archivable?).to be true
      expect(described_class.new("draft").archivable?).to be false
      expect(described_class.new("archived").archivable?).to be false
    end
  end

  describe "同値性" do
    it "同じ value なら == で等しい" do
      expect(described_class.new("draft")).to eq(described_class.new("draft"))
    end

    it "異なる value なら == で等しくない" do
      expect(described_class.new("draft")).not_to eq(described_class.new("published"))
    end

    it "Hash キーとして使える" do
      h = { described_class.new("draft") => 1 }
      expect(h[described_class.new("draft")]).to eq(1)
    end
  end

  describe "Article との連携" do
    it "article.status が ValueObjects::ArticleStatus を返す" do
      article = create(:article)
      expect(article.status).to be_an_instance_of(described_class)
    end

    it "draft 記事の status が draft? を返す" do
      article = create(:article)
      expect(article.status.draft?).to be true
    end
  end
end
