# frozen_string_literal: true

require 'yarr/query'
require 'yarr/command/base'
require 'yarr/command/concern/responder'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # Base class for all list commands
    class List < Base
      include Concern::Responder
      extend Concern::ASTDigger

      digger :class_name
      digger :method_name
      digger :origin_name

      define_multi_item_responder do |result|
        result.map(&:full_name).join(', ')
      end

      # Command handler
      def handle
        response(query)
      end
    end

    # Base class for list commands handling calls.
    class ListCall < List
      private

      def query
        Query::Method.where(
          Sequel.like(:name, method_name) &
          { klass: Query::Klass.where(Sequel.like(:name, class_name)),
            flavour: flavour }
        )
      end

      def target
        "#{flavour} method #{method_name} on #{class_name}"
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
        ast[:command] == 'list' && ast.key?(:instance_method)
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
        ast[:command] == 'list' && ast.key?(:class_method)
      end
    end

    # handles 'list Ar%' like commands
    class ListClassName < List
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'list' && ast.key?(:class_name)
      end

      private

      def query
        Query::Klass.where(Sequel.like(:name, class_name))
      end

      def target
        "class #{class_name}"
      end
    end

    # handles 'list si%' like commands
    class ListMethodName < List
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'list' && ast.key?(:method_name)
      end

      private

      def query
        Query::Method.where(Sequel.like(:name, method_name))
      end

      def target
        "method #{method_name}"
      end
    end
  end
end
