require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec_no_db) do |task|
  task.rspec_opts  = '--order rand'
end

task :spec do
  ENV['YARR_TEST'] = '1'
  Rake::Task['db:setup'].invoke
  Rake::Task['spec_no_db'].invoke
end
task :default => :spec

directory 'db'

namespace :db do
  desc 'Creates a new database (schema only)'
  task :create => :db do
    ruby 'db/schema.rb'
  end

  desc 'Drops the database if exists'
  task :drop do
    if ENV['YARR_TEST']
      rm_f 'db/test'
    else
      rm_f 'db/database'
    end
  end

  desc 'Seeds the database'
  task :seed do
    unless ENV['YARR_TEST']
      libs = Dir['db/seeds/**/*class_index.txt'].map do |fn|
        fn.delete_prefix('db/seeds/').delete_suffix('_class_index.txt')
      end

      libs.each { |lib| sh "ruby db/seed.rb #{lib}" }
    end
  end

  desc 'Sets up a new database'
  task :setup => %i[drop create seed]
end

namespace :lint do
  desc 'all lints'
  task :all => %i[spec_helper_check ci_build module_coverage]

  desc 'CI build'
  task :ci_build => %i[rubocop reek spec]

  desc 'Check for require spec_helper in spec files'
  task :spec_helper_check do
    puts "Listing files missing require 'spec_helper'"
    FileList['spec/**/*_spec.rb'].each do |f|
      File.open(f, 'r') do |io|
        puts f unless io.each_line.any?(/require 'spec_helper'/)
      end
    end
  end

  desc 'rubocop'
  task(:rubocop) { sh 'rubocop' }

  desc 'module level coverage'
  task :module_coverage do
    puts 'Module coverage checks'
    ENV['YARR_TEST'] = '1'
    sh 'deep-cover exec rspec'
  end

  desc 'reek'
  task(:reek) { sh 'reek -c .reek' }
end
