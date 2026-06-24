require "rails_helper"

RSpec.describe ValueObjects::NgWordPolicy do
  describe "#valid?" do
    context "NGワードを含まないテキスト" do
      it "true を返す" do
        expect(described_class.new("普通の文章です").valid?).to be true
      end
    end

    context "NGワードを含むテキスト（test環境: NG_TEST_WORD）" do
      it "false を返す" do
        expect(described_class.new("これはNG_TEST_WORDです").valid?).to be false
      end
    end

    context "空文字" do
      it "NGワードを含まないとみなす" do
        expect(described_class.new("").valid?).to be true
      end
    end
  end

  describe "#detected_words" do
    it "検出されたNGワードを返す" do
      policy = described_class.new("NG_TEST_WORDを含むテキスト")
      expect(policy.detected_words).to include("NG_TEST_WORD")
    end

    it "NGワードがなければ空配列を返す" do
      expect(described_class.new("普通のテキスト").detected_words).to be_empty
    end
  end

  describe "#errors" do
    it "NGワードが含まれるときエラーメッセージを返す" do
      policy = described_class.new("NG_TEST_WORDです")
      expect(policy.errors.first).to include("NG_TEST_WORD")
    end
  end

  describe "immutability" do
    it "freeze されている" do
      expect(described_class.new("text")).to be_frozen
    end
  end
end
