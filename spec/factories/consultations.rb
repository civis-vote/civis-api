FactoryBot.define do
  factory :consultation do
    title { "Consultation #{SecureRandom.hex(6)}" }
    url { Faker::Internet.url }
    department
    response_deadline { Date.today + 30.days }
    question_flow { :question_list }
    visibility { :public_consultation }
    status { :submitted }

    trait :published do
      status { :published }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :private do
      visibility { :private_consultation }
      organisation
    end
  end
end
