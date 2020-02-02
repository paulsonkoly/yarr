require 'deep_cover'
require 'faker'

require 'helpers/evaluator_response_double'

require 'yarr'

RSpec::Matchers.define :be_able_to_handle do |expected|
  match do |actual|
    actual.match? expected
  end
end
