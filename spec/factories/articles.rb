FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "記事タイトル #{n}" }
    body  { "本文テキスト" }
    status { "draft" }
    association :user  # User factory を自動で呼ぶ

    trait :published do
      status { "published" }
    end

    trait :with_tags do
      after(:create) do |article|
        article.tags << create(:tag)
      end
    end
  end
end
