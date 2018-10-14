require 'yarr/command/base'

module Yarr
  module Command
    class List < Base
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

    class ListClassName < List
      private

      def query
        Yarr::Query::Klass::Like.query(name: klass)
      end

      def error_message
        "I haven't found any entry that matches class #{klass}"
      end
    end

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
