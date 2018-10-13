require 'faker'

require 'simplecov'

SimpleCov.start do
  use_branchable_report true if respond_to?(:use_branchable_report)
  add_filter 'spec/'
end

# This require is there to ensure that all files required by our gem's main
# entry point are covered by simplecov.
require 'yarr'
