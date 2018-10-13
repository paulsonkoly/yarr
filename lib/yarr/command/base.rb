module Yarr
  module Command
    # Generic base class for command handling
    class Base
      # Responds to a command received
      # @param ast The parsed AST of a command target
      def handle(ast)
        raise NotImplementedError
      end
    end
  end
end
