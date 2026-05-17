require "rails_helper"

RSpec.describe ValueObjects::Email, type: :model do
  describe "初期化・正規化" do
    it "小文字化・前後空白除去して初期化される" do
      email = described_class.new("  User@Example.COM  ")
      expect(email.value).to eq("user@example.com")
    end

    it "String 以外を渡すと ArgumentError" do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
      expect { described_class.new(123) }.to raise_error(ArgumentError)
    end

    it "イミュータブル（frozen）である" do
      expect(described_class.new("a@b.com")).to be_frozen
    end
  end

  describe "派生情報" do
    let(:email) { described_class.new("user@example.com") }

    it "domain を返す" do
      expect(email.domain).to eq("example.com")
    end

    it "local_part を返す" do
      expect(email.local_part).to eq("user")
    end
  end

  describe "同値性" do
    it "正規化後の value が同じなら == で等しい" do
      expect(described_class.new("a@b.com")).to eq(described_class.new("a@b.com"))
    end

    it "大文字小文字が異なっても正規化後が同じなら等しい" do
      expect(described_class.new("A@B.COM")).to eq(described_class.new("a@b.com"))
    end

    it "Hash キーとして使える" do
      h = { described_class.new("a@b.com") => 1 }
      expect(h[described_class.new("a@b.com")]).to eq(1)
    end

    it "to_s が value を返す" do
      expect(described_class.new("a@b.com").to_s).to eq("a@b.com")
    end
  end

  describe "User との連携" do
    it "email_vo が ValueObjects::Email を返す" do
      user = create(:user, email: "User@Example.COM")
      expect(user.email_vo).to be_an_instance_of(described_class)
    end

    it "email_vo が正規化されたメールを返す" do
      user = create(:user, email: "User@Example.COM")
      expect(user.email_vo.value).to eq("user@example.com")
    end
  end
end
