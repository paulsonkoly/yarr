require 'yarr/query'

module Yarr
  module Command
    # &ri command handler. Looks up documentation link for the target.
    class Ri < Query
      private

      def handle_instance_method
        handle_call('instance')
      end

      def handle_class_method
        handle_call('class')
      end

      def handle_class_name
        result = Yarr::Query::Klass.query(name: @klass)

        response(count: result.count,
                 url_lambda: -> { result.first.url },
                 objects_string: "class #@klass")
      end

      def handle_method_name
        result = Yarr::Query::Method.query(name: @method)

        response(count: result.count,
                 url_lambda: -> { result.first.url },
                 objects_string: "method #@method",
                 advice: "Use &list #@method if you would like to see a list")
      end

      def handle_call(type)
        result = Yarr::Query::KlassAndMethod.query(method: @method,
                                                   klass: @klass,
                                                   flavour: type.to_s)

        response(count: result.count,
                 url_lambda: -> { result.first.method.url },
                 objects_string: "class #@klass #{type} method #@method")
      end

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
  end
end
