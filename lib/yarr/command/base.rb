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
    end
  end
end
