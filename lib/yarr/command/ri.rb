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

      def handle
        response(query)
      end

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
        super && ast.key?(:class_name)
      end

      private

      def query
        constraints = { name: class_name }
        if origin_name
          constraints[:origin] = Query::Origin.where(name: origin_name)
        end
        result = Query::Klass.where(constraints)
        select_appropriate(result)
      end

      def target
        "class #{class_name}"
      end

      def select_appropriate(result)
        if result.count > 1
          core = result.find(&:core?)
          return [core] if core

          default = result.find do |candidate|
            candidate.origin.name == class_name.downcase
          end
          return [default] if default
        end

        result
      end
    end
  end
end
