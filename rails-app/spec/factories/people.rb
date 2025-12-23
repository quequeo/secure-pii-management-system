FactoryBot.define do
  factory :person do
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    ssn { "#{rand(100..999)}-#{rand(10..99)}-#{rand(1000..9999)}" }
    street_address_1 { Faker::Address.street_address }
    street_address_2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip_code[0..4] }

    trait :without_middle_name do
      middle_name { nil }
    end

    trait :with_valid_ssn do
      ssn { "123-45-6789" }
    end
  end
end
