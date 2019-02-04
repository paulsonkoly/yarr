require 'yarr/database'
require 'yarr/query/origin'
require 'yarr/query/url_corrector'

module Yarr
  module Query
    # Class model
    #
    # Stores either a Ruby class or a module. Tracks where it is defined, core
    # or some other gem. With Ruby classes being open, it is possible that a
    # single class has definitions from multiple places. Yarr does not (and can
    # not) distinguish between these however core is handled as a special case.
    #
    # @example
    #    klass = Yarr::Query::Klass.where(name: 'Array').first
    #    klass.name # => "Array"
    #    klass.flavour # => "C"
    #    klass.url # => "https://ruby-doc.org/core-2.6/Array.html"
    #    klass.origin
    #      # => #<Yarr::Query::Origin @values={:id=>1, :name=>"core"}>
    class Klass < Sequel::Model
      prepend URLCorrector

      many_to_one :origin
      one_to_many :methods

      # @!attribute [r] name
      #   @return [String] class name
      # @!attribute [r] flavour
      #   @return [String] 'class' or 'module'
      # @!attribute [r] url
      #   @return [String] ri documentation for class
      # @!attribute [r] origin
      #   @return [Origin] originating gem

      # @return [String] the name of the class
      def full_name
        name + (core? ? '' : " (#{origin.name})")
      end
    end
  end
end
