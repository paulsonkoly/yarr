# frozen_string_literal: true

RSpec::Matchers.define :be_able_to_handle do |expected|
  match do |actual|
    actual.match? expected
  end
end
