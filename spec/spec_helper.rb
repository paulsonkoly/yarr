require 'faker'

require 'simplecov'

SimpleCov.start do
  use_branchable_report true if respond_to?(:use_branchable_report)
end
