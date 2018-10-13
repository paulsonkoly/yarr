module Yarr
  module Command
    # List command handler. Returns a matching list for the target.
    class List < Query
      private

      def handle_instance_method
        handle_call('instance', '#')
      end

      def handle_class_method
        handle_call('class', '.')
      end

      def handle_class_name
        result = Yarr::Query::Klass.query(name: @klass, allow_like: true)

        if result.count.zero?
          "I haven't found any entry that matches class #@klass"
        else
          result.entries.join(', ')
        end
      end

      def handle_method_name
        result = Yarr::Query::Method.query(name: @method, allow_like: true)

        if result.count.zero?
          "I haven't found any entry that matches method #@method"
        else
          result.entries.join(', ')
        end
      end

      def handle_call(type, type_delimiter)
        result = Yarr::Query::KlassAndMethod.query(klass: @klass,
                                                   method: @method,
                                                   flavour: type.to_s,
                                                   allow_like: true)
        if result.count.zero?
          "I haven't found any entry that matches #{type} method #@method on class #@klass"
        else
          result.entries.join(', ')
        end
      end
    end
  end
end
