FactoryBot.define do
  factory :audit_log do
    action { "view" }
    auditable_type { "Person" }
    auditable_id { 1 }
    user_identifier { Faker::Internet.ip_v4_address }
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    details { "Viewed Person #1" }

    trait :view_action do
      action { "view" }
      details { "Viewed #{auditable_type} ##{auditable_id}" }
    end

    trait :create_action do
      action { "create" }
      details { "Created #{auditable_type} ##{auditable_id}" }
    end

    trait :update_action do
      action { "update" }
      details { "Updated #{auditable_type} ##{auditable_id}" }
    end

    trait :destroy_action do
      action { "destroy" }
      details { "Deleted #{auditable_type} ##{auditable_id}" }
    end

    trait :with_person do
      association :auditable, factory: :person
    end
  end
end
