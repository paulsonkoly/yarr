require 'yarr/command/base'
require 'yarr/query'
require 'yarr/command/concern/responder'

module Yarr
  module Command
    # Base class for all ri commands
    class Ri < Base
      include Concern::Responder

      def handle
        response(query)
      end

      define_single_item_responder { |result| result.first.url }

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'ri'
      end
    end

    # Base class for ri commands handling calls.
    class RiCall < Ri
      private

      def query
        Query::Method.where(name: method,
                            flavour: flavour,
                            klass: Query::Klass.where(name: klass))
      end

      def target
        "class #{klass} #{flavour} method #{method}"
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
        super && ast.key?(:instance_method)
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
        super && ast.key?(:class_method)
      end
    end

    # Handles 'ri size' like commands
    class RiMethodName < Ri
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        super && ast.key?(:method_name)
      end

      private

      def query
        Query::Method.where(name: method)
      end

      def target
        "method #{method}"
      end

      def advice
        "Use &list #{method} if you would like to see a list"
      end
    end

    # Handles 'ri File' like commands
    class RiClassName < Ri
      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        super && ast.key?(:class_name)
      end

      private

      def query
        constraints = { name: klass }
        constraints[:origin] = Query::Origin.where(name: origin) if origin
        result = Query::Klass.where(constraints)
        select_core(result)
      end

      def target
        "class #{klass}"
      end

      def select_core(result)
        if result.count > 1
          core = result.find(&:core?)
          return [core] if core
        end

        result
      end
    end
  end
end
