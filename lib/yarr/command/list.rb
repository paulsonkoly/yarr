require 'yarr/command/base'

module Yarr
  module Command
    # list command handler
    class List < Base
      # @return [String] found entries joined by ', '
      def handle
        result = query
        return error_message if result.count.zero?

        result.entries.join(', ')
      end

      private

      def query
        raise NotImplementedError
      end

      def error_message
        raise NotImplementedError
      end
    end

    # handles 'list Ar%#si%' like commands
    class ListInstanceMethod < List
      private

      def query
        Yarr::Query::KlassAndMethod::Like.query(klass: klass,
                                                method: method,
                                                flavour: 'instance')
      end

      def error_message
        "I haven't found any entry that matches instance method #{method} on class #{klass}"
      end
    end

    # handles 'list Ar%.si%' like commands
    class ListClassMethod < List
      private

      def query
        Yarr::Query::KlassAndMethod::Like.query(klass: klass,
                                                method: method,
                                                flavour: 'class')
      end

      def error_message
        "I haven't found any entry that matches class method #{method} on class #{klass}"
      end
    end

    # handles 'list Ar%' like commands
    class ListClassName < List
      private

      def query
        Yarr::Query::Klass::Like.query(name: klass)
      end

      def error_message
        "I haven't found any entry that matches class #{klass}"
      end
    end

    # handles 'list si%' like commands
    class ListMethodName < List
      private

      def query
        Yarr::Query::Method::Like.query(name: method)
      end

      def error_message
        "I haven't found any entry that matches method #{method}"
      end
    end
  end
end
