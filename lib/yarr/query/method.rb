require 'yarr/query/url_corrector'

module Yarr
  module Query
    # Method model
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

      # method name qualified with class:: or class.
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
