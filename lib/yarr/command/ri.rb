# frozen_string_literal: true

require 'yarr/command/base'
require 'yarr/query'
require 'yarr/command/concern/responder'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # Base class for all ri commands
    class Ri < Base
      include Concern::Responder
      extend Concern::ASTDigger

      digger :class_name
      digger :method_name
      digger :origin_name

      define_single_item_responder { |result| result.first.url }

      # Runs the command
      def handle
        response(query)
      end
    end

    # Base class for ri commands handling calls.
    class RiCall < Ri
      private

      def query
        Query::Method.where(name: method_name,
                            flavour: flavour,
                            klass: Query::Klass.where(name: class_name))
      end

      def target
        "class #{class_name} #{flavour} method #{method_name}"
      end
    end

    # Handles 'ri Array#size' like commands
    class RiInstanceMethod < RiCall
      private def flavour
        'instance'
      end

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'ri' && ast.key?(:instance_method)
      end
    end

    # Handles 'ri Array.size' like commands
    class RiClassMethod < RiCall
      private def flavour
        'class'
      end

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'ri' && ast.key?(:class_method)
      end
    end

    # Handles 'ri size' like commands
    class RiMethodName < Ri
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'ri' && ast.key?(:method_name)
      end

      private

      def query
        Query::Method.where(name: method_name)
      end

      def target
        "method #{method_name}"
      end

      def advice
        "Use &list #{method_name} if you would like to see a list"
      end
    end

    # Handles 'ri File' like commands
    class RiClassName < Ri
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'ri' && ast.key?(:class_name)
      end

      # @private
      # Wraps the Sequel::Dataset for class names with the logic that prefers
      # cores and origins with same name
      class QueryResult
        def initialize(dataset)
          @dataset = dataset.all
        end

        def appropriate
          if @dataset.count > 1
            with_core { |core| return [core] }
            with_same_origin { |klass| return [klass] }
          end

          @dataset
        end

        private

        def with_core(&block)
          @dataset.select(&:core?).each(&block)
        end

        def with_same_origin(&block)
          @dataset.select(&:same_origin?).each(&block)
        end
      end
      private_constant :QueryResult

      private

      def query
        constraints = { name: class_name }
        constraints[:origin] = Query::Origin.where(name: origin_name) if origin_name
        result = QueryResult.new(Query::Klass.where(constraints))
        result.appropriate
      end

      def target
        "class #{class_name}"
      end
    end
  end
end
