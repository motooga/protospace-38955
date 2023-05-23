FactoryBot.define do
  factory :prototype do
    title {Faker::Movie.title}
    catch_copy {Faker::Lorem.sentence}
    concept {Faker::Lorem.sentence}

    association :user

    after(:build) do |prototype|
      prototype.image.attach(io: File.open('public/images/test-image.png'), filename: 'test_image.png')
    end
  end
end
