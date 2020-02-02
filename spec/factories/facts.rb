FactoryBot.define do
  factory :fact, class: 'Yarr::Query::Fact' do
    name { 'pizza' }
    content { "here's your pizza: 🍕" }
    count { 0 }

    to_create(&:save)
  end
end
