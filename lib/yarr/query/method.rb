# frozen_string_literal: true

require 'yarr/database'
require 'yarr/query/origin'
require 'yarr/query/klass'
require 'yarr/query/url_corrector'

module Yarr
  module Query
    # Method model
    #
    # A method belongs to a class or a module and can be instance or class
    # method. As far as the Ruby language goes this is a slight bend of
    # reality, but mainly follows ri conventions.
    #
    # @example
    #    m = Yarr::Query::Method.where(name: '<<').first
    #    m.name # => "<<"
    #    m.flavour # => "instance"
    #    m.url # => "https://ruby-doc.org/core-2.6/Array.html#method-i-3C-3C"
    #    m.origin # => #<Yarr::Query::Origin @values={:id=>1, :name=>"core"}>
    #    m.full_name # => "Array#<<"
    class Method < Sequel::Model
      prepend URLCorrector

      many_to_one :origin
      many_to_one :klass

      # @!attribute [r] name
      #   @return [String] class name
      # @!attribute [r] flavour
      #   @return [String] 'class' or 'instance'
      # @!attribute [r] url
      #   @return [String] ri documentation for method
      # @!attribute [r] origin
      #   @return [Origin] originating gem

      # method name qualified with +class#+ or +class.+
      # @return [String] Class#name or Class.name
      def full_name
        "#{klass.name}#{flavour_separator}#{name}"
      end

      private

      def flavour_separator
        case flavour
        when 'instance' then '#'
        when 'class' then '.'
        end
      end
    end
  end
end
