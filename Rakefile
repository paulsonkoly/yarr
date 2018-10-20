require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec_no_db)
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
    if ENV['YARR_TEST']
      sh 'ruby db/test_seed.rb'
    else
      # TODO io, net
      libs = %w[ core abbrev base64 benchmark cgi
                 cmath coverage csv date dbm
                 delegate English
                 expect extmk fcntl fiddle fileutils
                 find forwardable gdbm getoptlong ipaddr
                 logger matrix mkmf monitor
                 mutex_m nkf objspace observer open3
                 openssl open-uri optparse ostruct pathname prettyprint
                 prime profile profiler pstore psych pty
                 racc rake rdoc readline resolv resolv-replace
                 rexml rinda ripper rss rubygems scanf
                 sdbm securerandom set shell shellwords singleton
                 socket stringio strscan sync syslog tempfile
                 thwait time timeout tmpdir tracer tsort
                 un unicode_normalize uri weakref webrick win32ole
                 yaml zlib ]
      libs.each { |lib| sh "ruby db/seed.rb #{lib}" }
    end
  end

  desc 'Sets up a new database'
  task :setup => [:drop, :create, :seed]
end

namespace :lint do
  desc 'all lints'
  task :all => [:spec_helper_check, :no_byebug, :reek, :spec, :module_coverage]

  desc 'Check for require spec_helper in spec files'
  task :spec_helper_check do
    puts "Listing files missing require 'spec_helper'"
    FileList['spec/**/*_spec.rb'].each do |f|
      File.open(f, 'r') do |io|
        puts f unless io.each_line.any?(/require 'spec_helper'/)
      end
    end
  end

  desc 'byebug should not be checked in'
  task :no_byebug do
    puts 'looking for files with byebug'
    FileList['**/*.rb'].each do |f|
      File.open(f, 'r') do |io|
        abort "byebug found in #{f}" if io.each_line.any? /byebug/
      end
    end
  end

  desc 'module coverage for file'
  task :coverage_for, [:file] do |task, args|
    target = args[:file]
    basename = File.basename(target, '.rb')
    dirname = File.dirname(target).sub(/\blib\b/, 'spec')
    specname = "#{dirname}/#{basename}_spec.rb"
    ENV['MODULE_COVERAGE_FILE'] = File.basename(target)
    ENV['MODULE_COVERAGE_SPEC'] = specname
    sh "rspec -r module_coverage #{specname}"
  end

  desc 'module level coverage'
  task :module_coverage do
    puts "Module coverage checks"
    list = FileList['lib/**/*.rb']
    list.exclude('lib/yarr.rb',
                 'lib/yarr/bot.rb',
                 'lib/yarr/command.rb',
                 'lib/yarr/database.rb',
                 'lib/yarr/query.rb',
                 'lib/yarr/version.rb')
    list.each do |f|
      ENV['YARR_TEST'] = '1'
      ENV['MODULE_COVERAGE_ASSERT'] = 'true'
      Rake::Task['lint:coverage_for'].invoke(f)
      Rake::Task['lint:coverage_for'].reenable
    end
  end

  desc 'reek'
  task(:reek) { sh 'reek -c .reek' }
end
