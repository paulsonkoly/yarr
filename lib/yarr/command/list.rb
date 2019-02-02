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

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'list'
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
    end

    # handles 'list Ar%#si%' like commands
    class ListInstanceMethod < ListCall
      private def flavour
        'instance'
      end

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        super && ast.key?(:instance_method)
      end
    end

    # handles 'list Ar%.si%' like commands
    class ListClassMethod < ListCall
      private def flavour
        'class'
      end

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        super && ast.key?(:class_method)
      end
    end

    # handles 'list Ar%' like commands
    class ListClassName < List
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        super && ast.key?(:class_name)
      end

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
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        super && ast.key?(:method_name)
      end

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
