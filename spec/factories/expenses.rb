FactoryBot.define do 
  factory :expense do 
    title { Faker::Name.name[0, 15] }
    amount { Faker::Number.between(from: 1, to: 1000)}
    spent_on { Faker::Date.backward(days: 30)}

    association :user

    trait :without_title do
      title { nil }
    end

    trait :without_amount do
      amount { nil }
    end

    trait :without_spent_on do
      spent_on { nil }
    end

    trait :without_user do 
      user { nil }
    end
  end
end

