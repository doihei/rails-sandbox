require "rails_helper"

RSpec.describe ValueObjects::CommentBody, type: :model do
  describe "初期化・正規化" do
    it "前後の空白を除去して value に格納する" do
      expect(described_class.new("  hello  ").value).to eq("hello")
    end

    it "nil を渡すと空文字として扱う" do
      expect(described_class.new(nil).value).to eq("")
    end

    it "freeze されている" do
      expect(described_class.new("hello")).to be_frozen
    end
  end

  describe "#valid?" do
    context "通常の文字列" do
      it "true を返す" do
        expect(described_class.new("正常なコメント本文").valid?).to be true
      end
    end

    context "ちょうど MAX_LENGTH 文字" do
      it "true を返す" do
        expect(described_class.new("a" * described_class::MAX_LENGTH).valid?).to be true
      end
    end

    context "空文字" do
      it "false を返す" do
        expect(described_class.new("").valid?).to be false
      end
    end

    context "空白のみ（strip で空になる）" do
      it "false を返す" do
        expect(described_class.new("   ").valid?).to be false
      end
    end

    context "MAX_LENGTH + 1 文字" do
      it "false を返す" do
        expect(described_class.new("a" * (described_class::MAX_LENGTH + 1)).valid?).to be false
      end
    end
  end

  describe "#errors" do
    it "空文字のとき body_blank のエラーメッセージを返す" do
      errors = described_class.new("").errors
      expect(errors).to include(I18n.t("comments.errors.body_blank"))
    end

    it "MAX_LENGTH 超のとき body_too_long のエラーメッセージを返す" do
      errors = described_class.new("a" * (described_class::MAX_LENGTH + 1)).errors
      expect(errors).to include(I18n.t("comments.errors.body_too_long", max: described_class::MAX_LENGTH))
    end

    it "正常な文字列のときエラーは空" do
      expect(described_class.new("正常なコメント").errors).to be_empty
    end
  end

  describe "同値性" do
    it "同じ value なら == で等しい" do
      expect(described_class.new("hello")).to eq(described_class.new("hello"))
    end

    it "空白が strip されて同じ value になれば等しい" do
      expect(described_class.new("  hello  ")).to eq(described_class.new("hello"))
    end

    it "異なる value なら等しくない" do
      expect(described_class.new("hello")).not_to eq(described_class.new("world"))
    end

    it "Hash キーとして使える（eql? / hash が一致）" do
      a = described_class.new("hello")
      b = described_class.new("hello")
      expect({ a => 1 }[b]).to eq(1)
    end
  end

  describe "#to_s" do
    it "strip 後の value を返す" do
      expect(described_class.new("  hello  ").to_s).to eq("hello")
    end
  end

  describe "#inspect" do
    it "クラス名と value を含む文字列を返す" do
      expect(described_class.new("hello").inspect).to eq('#<ValueObjects::CommentBody value="hello">')
    end
  end
end
