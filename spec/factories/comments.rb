FactoryBot.define do
  factory :comment do
    body { "コメント本文" }
    association :article
    association :user
  end
end
