module Yarr
  module Command
    # Generic base class for command handling.
    #
    # A command receives a parsed AST from the bot and responds with some
    # string to it.
    class Base
      # @param ast The parsed AST of a command target
      def initialize(ast)
        @ast = ast
      end

      attr_reader :ast

      private

      def self.digger(name, ast_name = :"#{name}_name")
        define_method(name) { @ast.dig_deep(ast_name) }
      end
      private_class_method :digger

      digger :klass, :class_name
      digger :method
      digger :origin
    end
  end
end
