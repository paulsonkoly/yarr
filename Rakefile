require "bundler/gem_tasks"

task :default => :spec

directory 'db'

namespace :db do
  desc 'Creates a new database (schema only)'
  task :create_database => :db do
    ruby 'db/schema.rb'
  end

  desc 'Drops the database if exists'
  task :drop_database do
    rm 'db/database'
  end

  desc 'Seeds the database'
  task :seed do
    ruby 'db/seed.rb'
  end

  desc 'Sets up a new database'
  task :setup => [:drop_database, :create_database, :seed]
end
