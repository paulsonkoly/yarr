require 'yarr/query/url_corrector'

module Yarr
  module Query
    class Klass < Sequel::Model
      prepend URLCorrector

      many_to_one :origin
      one_to_many :methods

      # @return [String] the name of the class
      def full_name
        name + (core? ? '' : " (#{origin.name})")
      end

    end
  end
end
