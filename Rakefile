require "bundler/gem_tasks"
require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new(:spec_no_db)
task :spec do
  ENV['TEST'] = '1'
  Rake::Task['db:setup'].invoke
  Rake::Task['spec_no_db'].invoke
end
task :default => :spec

directory 'db'

namespace :db do
  desc 'Creates a new database (schema only)'
  task :create_database => :db do
    ruby 'db/schema.rb'
  end

  desc 'Drops the database if exists'
  task :drop_database do
    if ENV['TEST']
      rm_f 'db/test'
    else
      rm_f 'db/database'
    end
  end

  desc 'Seeds the database'
  task :seed do
    ruby 'db/seed.rb'
  end

  desc 'Sets up a new database'
  task :setup => [:drop_database, :create_database, :seed]
end

namespace :lint do
  desc 'all lints'
  task :all => [:spec_helper_check, :reek, :spec, :module_coverage]

  desc 'Check for require spec_helper in spec files'
  task :spec_helper_check do
    puts 'Listing files missing the require:'
    FileList['spec/**/*_spec.rb'].each do |f|
      File.open(f, 'r') do |io|
        puts f unless io.each_line.any?(/require 'spec_helper'/)
      end
    end
  end

  desc 'module level coverage'
  task :module_coverage do
    puts <<~EOS

      Only run this if you want to check per module coverage

    EOS
    list = FileList['lib/**/*.rb']
    list.exclude('lib/yarr.rb',
                 'lib/yarr/bot.rb',
                 'lib/yarr/command.rb',
                 'lib/yarr/database.rb',
                 'lib/yarr/query.rb',
                 'lib/yarr/version.rb')
    list.each do |f|
      basename = File.basename(f, '.rb')
      dirname = File.dirname(f).sub(/\blib\b/, 'spec')
      specname = "#{dirname}/#{basename}_spec.rb"
      ENV['MODULE_COVERAGE_FILE'] = File.basename(f)
      ENV['MODULE_COVERAGE_SPEC'] = specname
      ENV['TEST'] = '1'
      sh "rspec -o /dev/null -r module_coverage #{specname}"
    end
  end

  desc 'reek'
  task(:reek) { sh 'reek -c .reek' }
end
