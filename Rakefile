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

namespace :lint do
  desc 'Check for require spec_helper in spec files'
  task :spec_helper_check do
    puts 'Listing files missing the require:'
    Dir['spec/**/*_spec.rb'].each do |f|
      File.open(f, 'r') do |io|
        puts f unless io.each_line.any?(/require 'spec_helper'/)
      end
    end
  end
end
