RSpec.configure do |config|
  config.after(:suite) do
    file = SimpleCov.result.files.find do |f|
      File.basename(f.filename) == ENV['MODULE_COVERAGE_FILE']
    end

    if file.covered_percent < 100
      abort <<~EOS

       ********

       File #{file.filename} is only #{file.covered_percent}% covered at module level

       to reproduce this run : bundle exec rspec #{ENV['MODULE_COVERAGE_SPEC']}
       and inspect coverage/index.html. Note that only #{file.filename} is
       supposed to have 100% coverage.

       ********
      EOS
    end
    abort "Missed branch in #{file.filename} at module level" unless file.missed_branches.empty?
  end
end
