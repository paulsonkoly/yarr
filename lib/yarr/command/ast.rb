require 'yarr/command/base'

module Yarr
  module Command
    # Debug command, useful to see how our parser works
    class AST < Base
      # @return [String]
      def handle
        ast.inspect
      end

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'ast'
      end
    end
  end
end
