require 'yarr/command/base'
require 'yarr/query'

module Yarr
  module Command
    # ri command handler
    class Ri < Base
      private

      def response(result:, objects_string:, advice: nil)
        count = result.count
        case count
        when 0 then "Found no entry that matches #{objects_string}."
        when 1 then "https://ruby-doc.org/core-2.5.1/#{url(result)}"
        else
          [ "I found #{count} entries matching with #{objects_string}.",
            advice
          ].compact.join(' ')
        end
      end
    end

    # Handles 'ri Array#size' like commands
    class RiInstanceMethod < Ri
      # @return [String] documentation url
      def handle
        result = Yarr::Query::KlassAndMethod::Strict.query(method: method,
                                                           klass: klass,
                                                           flavour: 'instance')

        response(result: result,
                 objects_string: "class #{klass} instance method #{method}")
      end

      private

      def url(result)
        result.first.method.url
      end
    end

    # Handles 'ri File.size' like commands
    class RiClassMethod < Ri
      # @return [String] documentation url
      def handle
        result = Yarr::Query::KlassAndMethod::Strict.query(method: method,
                                                           klass: klass,
                                                           flavour: 'class')

        response(result: result,
                 objects_string: "class #{klass} class method #{method}")
      end

      private

      def url(result)
        result.first.method.url
      end
    end

    # Handles 'ri size' like commands
    class RiMethodName < Ri
      # @return [String] documentation url
      def handle
        result = Yarr::Query::Method::Strict.query(name: method)

        response(result: result,
                 objects_string: "method #{method}",
                 advice: "Use &list #{method} if you would like to see a list")
      end

      private

      def url(result)
        result.first.url
      end
    end

    # Handles 'ri File' like commands
    class RiClassName < Ri
      # @return [String] documentation url
      def handle
        result = Yarr::Query::Klass::Strict.query(name: klass)

        response(result: result, objects_string: "class #{klass}")
      end

      private

      def url(result)
        result.first.url
      end
    end
  end
end
