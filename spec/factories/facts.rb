# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :fact, class: 'Yarr::Query::Fact' do
    name { Faker::TvShows::Buffy.character }
    content { Faker::TvShows::Buffy.quote }
    count { 0 }

    to_create(&:save)
  end
end
