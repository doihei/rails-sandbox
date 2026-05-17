require "rails_helper"

RSpec.describe ValueObjects::TagNameList, type: :model do
  describe "初期化・正規化" do
    it "カンマ区切り文字列をパースする" do
      list = described_class.new("Rails, Ruby")
      expect(list.names).to eq([ "rails", "ruby" ])
    end

    it "前後空白を除去・小文字化する" do
      list = described_class.new("  Rails  ,  Ruby  ")
      expect(list.names).to eq([ "rails", "ruby" ])
    end

    it "重複を排除する" do
      list = described_class.new("Rails, ruby, RAILS")
      expect(list.names).to eq([ "rails", "ruby" ])
    end

    it "空文字列で初期化すると空になる" do
      list = described_class.new("")
      expect(list.names).to be_empty
    end

    it "nil で初期化すると空になる" do
      list = described_class.new(nil)
      expect(list.names).to be_empty
    end

    it "nil や 空文字で empty? が true" do
      expect(described_class.new(nil).empty?).to be true
      expect(described_class.new("").empty?).to be true
    end

    it "Integer を渡すと ArgumentError" do
      expect { described_class.new(123) }.to raise_error(ArgumentError)
    end

    it "リスト自体と names 配列どちらも frozen" do
      list = described_class.new("rails")
      expect(list).to be_frozen
      expect(list.names).to be_frozen
    end
  end

  describe "同値性" do
    it "同じ名前リストなら == で等しい" do
      expect(described_class.new("rails, ruby")).to eq(described_class.new("rails, ruby"))
    end

    it "順序が異なっても names の並びが同じなら等しい" do
      a = described_class.new("ruby, rails")
      b = described_class.new("ruby, rails")
      expect(a).to eq(b)
    end
  end

  describe "to_s" do
    it "names をカンマ+スペース区切りで返す" do
      list = described_class.new("rails, ruby")
      expect(list.to_s).to eq("rails, ruby")
    end
  end
end
