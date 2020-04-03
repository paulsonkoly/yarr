# frozen_string_literal: true

require 'deep_cover'
require 'faker'
require 'factory_bot'
require 'database_cleaner'

%w[matchers helpers shared_examples shared_contexts].each do |directory|
  Dir.chdir('spec') do
    Dir.glob("#{directory}/**/*.rb").sort.each do |file|
      require file
    end
  end
end

require 'yarr'

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
