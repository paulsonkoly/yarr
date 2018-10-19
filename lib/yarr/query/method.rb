require 'yarr/query/url_corrector'

module Yarr
  module Query
    class Method < Sequel::Model
      prepend URLCorrector

      many_to_one :origin
      many_to_one :klass

      def full_name
        "#{klass.name}#{flavour_separator}#{name}"
      end

      private

      def flavour_separator
        case flavour
        when 'instance' then '#'
        when 'class' then '.'
        else '???'
        end
      end
    end
  end
end
