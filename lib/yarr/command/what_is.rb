require 'yarr/command/base'

module Yarr
  module Command
    # Gets the first key out of the AST and replies with it, underscores
    # translated to spaces.
    class WhatIs < Base
      # @return [String]
      def handle
        "It's a(n) #{ast.first.first}.".tr '_', ' '
      end
    end
  end
end
