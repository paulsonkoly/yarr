source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'cinch', '~> 2.3.4'
gem 'sequel'
gem 'sqlite3'
gem 'parslet'
gem 'activesupport'
gem 'app_configuration'

group :development do
  gem 'byebug'
  gem 'pry'
  gem 'reek', '~> 5.2.0'
end

group :test do
  gem 'rspec'
  gem 'faker'
  gem 'simplecov'
end

# Specify your gem's dependencies in yarr.gemspec
gemspec
