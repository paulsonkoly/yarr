require 'yarr/database'
require 'yarr/query/result'
require 'yarr/query/method'
require 'yarr/query/klass'
require 'yarr/query/klass_and_method.rb'

module Yarr
  # OO database interface to our database accesses. Classes provide a class
  # method .query for instance {Method::Strict.query}. These functions return a
  # {Result} object which contains instances of the former class,
  # {Method::Strict} in this case.
  module Query
  end
end
