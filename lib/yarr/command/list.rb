require 'yarr/query'
require 'yarr/command/base'
require 'yarr/command/concern/responder'

module Yarr
  module Command
    # Base class for all list commands
    class List < Base
      include Concern::Responder

      respond_with response: ->(result) { result.map(&:full_name).join(', ') }

      # Command handler
      def handle
        response(query)
      end

      private

      def query
        raise NotImplementedError
      end

      def target
        raise NotImplementedError
      end
    end

    # Base class for list commands handling calls.
    class ListCall < List
      private

      def query
        Query::Method.where(
          Sequel.like(:name, method) &
          { klass: Query::Klass.where(Sequel.like(:name, klass)),
            flavour: flavour }
        )
      end

      def target
        "#{flavour} method #{method} on #{klass}"
      end

      def flavour
        raise NotImplementedError
      end
    end

    # handles 'list Ar%#si%' like commands
    class ListInstanceMethod < ListCall
      private def flavour
        'instance'
      end
    end

    # handles 'list Ar%.si%' like commands
    class ListClassMethod < ListCall
      private def flavour
        'class'
      end
    end

    # handles 'list Ar%' like commands
    class ListClassName < List
      private

      def query
        Query::Klass.where(Sequel.like(:name, klass))
      end

      def target
        "class #{klass}"
      end
    end

    # handles 'list si%' like commands
    class ListMethodName < List
      private

      def query
        Query::Method.where(Sequel.like(:name, method))
      end

      def target
        "method #{method}"
      end
    end
  end
end
