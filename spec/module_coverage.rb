require 'simplecov'

if ENV['MODULE_COVERAGE_ASSERT'] == 'true'
  RSpec.configure do |config|
    config.after(:suite) do
      file = SimpleCov.result.files.find do |f|
        File.basename(f.filename) == ENV['MODULE_COVERAGE_FILE']
      end

      expect(file.covered_percent).to be >= 100
      expect(file.missed_branches).to be_empty
    end
  end
end

SimpleCov.start do
  use_branchable_report true if respond_to?(:use_branchable_report)
  add_filter 'spec/'
end
