module Yarr
  module Command
    # Gets the first key out of the AST and replies with it, underscores
    # translated to spaces.
    class WhatIs < Base
      # Takes an AST and returns the response.
      def handle(ast)
        "It's a(n) #{ast.first.first}.".tr '_', ' '
      end
    end
  end
end
