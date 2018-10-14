require 'yarr/command/base'
require 'yarr/query'

module Yarr
  module Command
    class Ri < Base
      private

      def response(count:, url_lambda:, objects_string:, advice: nil)
        case count
        when 0 then "Found no entry that matches #{objects_string}."
        when 1 then "https://ruby-doc.org/core-2.5.1/#{url_lambda.call}"
        else
          [ "I found #{count} entries matching with #{objects_string}.",
            advice
          ].compact.join(' ')
        end
      end
    end

    class RiInstanceMethod < Ri
      def handle
        result = Yarr::Query::KlassAndMethod.query(method: method,
                                                   klass: klass,
                                                   flavour: 'instance')

        response(count: result.count,
                 url_lambda: -> { result.first.method.url },
                 objects_string: "class #{klass} instance method #{method}")
      end
    end

    class RiClassMethod < Ri
      def handle
        result = Yarr::Query::KlassAndMethod.query(method: method,
                                                   klass: klass,
                                                   flavour: 'class')

        response(count: result.count,
                 url_lambda: -> { result.first.method.url },
                 objects_string: "class #{klass} class method #{method}")
      end
    end

    class RiMethodName < Ri
      def handle
        result = Yarr::Query::Method::Strict.query(name: method)

        response(count: result.count,
                 url_lambda: -> { result.first.url },
                 objects_string: "method #{method}",
                 advice: "Use &list #{method} if you would like to see a list")
      end
    end

    class RiClassName < Ri
      def handle
        result = Yarr::Query::Klass::Strict.query(name: klass)

        response(count: result.count,
                 url_lambda: -> { result.first.url },
                 objects_string: "class #{klass}")
      end
    end
  end
end
