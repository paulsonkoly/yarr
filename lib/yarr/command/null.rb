require 'yarr/command/base'

module Yarr
  module Command
    # Null command. When all else fails to match the AST we can still handle it.
    class Null < Base
      def handle
        "No command could handle #{ast.inspect}."
      end
    end
  end
end
