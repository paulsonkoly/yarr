source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'cinch', git: 'https://github.com/cinchrb/cinch.git'
gem 'xdg', git: 'https://github.com/rubyworks/xdg.git'
gem 'sequel'
gem 'sqlite3'
gem 'parslet'
gem 'activesupport'

group :development do
  gem 'byebug'
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'faker'
  gem 'simplecov'
end

# Specify your gem's dependencies in yarr.gemspec
gemspec
