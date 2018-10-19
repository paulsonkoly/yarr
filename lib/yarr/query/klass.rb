require 'yarr/query/url_corrector'

module Yarr
  module Query
    # Klass model
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
