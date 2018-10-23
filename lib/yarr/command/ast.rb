require 'yarr/command/base'

module Yarr
  module Command
    # Debug command, useful to see how our parser works
    class AST < Base
      # @return [String]
      def handle
        ast.inspect
      end
    end
  end
end
