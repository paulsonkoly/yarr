require 'yarr/command/base'

module Yarr
  module Command
    # Gets the first key out of the AST and replies with it, underscores
    # translated to spaces.
    class AST < Base
      # @return [String]
      def handle
        ast.inspect
      end
    end
  end
end
