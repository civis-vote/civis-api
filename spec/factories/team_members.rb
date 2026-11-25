FactoryBot.define do
  factory :team_member do
    name { Faker::Name.name }
    designation { Faker::Job.title }
    status { :active }
    member_type { :team }

    after(:build) do |team_member|
      team_member.profile_picture.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/sample.png')),
        filename: 'sample.png',
        content_type: 'image/png'
      )
    end
  end
end
