require 'deep_cover'
require 'faker'
require 'factory_bot'
require 'database_cleaner'

require 'helpers/evaluator_response_double'
require 'helpers/ast_matcher'
require 'shared_examples/a_command_that_authorizes'

require 'yarr'

RSpec::Matchers.define :be_able_to_handle do |expected|
  match do |actual|
    actual.match? expected
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
