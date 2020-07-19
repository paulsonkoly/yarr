source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'app_configuration'
gem 'cinch', '~> 2.3'
gem 'dry-equalizer', '~> 0.2'
gem 'faker', '~> 1.9'
gem 'parslet', '~> 1.8'
gem 'sequel', '~> 5.18'
gem 'sqlite3', '~> 1.4'
gem 'typhoeus', '~> 1.3'

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'mutant-rspec'
  gem 'nokogiri'
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'reek'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end

group :development, :test do
  gem 'database_cleaner-sequel'
  gem 'deep-cover'
  gem 'factory_bot'
  gem 'rspec'
end

# Specify your gem's dependencies in yarr.gemspec
gemspec
