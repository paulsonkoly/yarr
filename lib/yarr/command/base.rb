require 'yarr/no_irc'
require 'yarr/dependencies'

module Yarr
  module Command
    # Generic base class for command handling.
    #
    # A command receives a parsed {AST} from the bot and responds with some
    # string to it.
    class Base
      include Import['irc']

      # Creates a command that handles the parsed input
      # @param ast [Yarr:AST] the parsed input
      def initialize(ast:, **args)
        super(**args)

        @ast = ast
      end

      # @!attribute [r] ast
      #   @return [Yarr::AST] the handled ast structure
      attr_reader :ast

      # Runs the command
      def handle
        "#{self.class} doesn't know how to handle #{ast}"
      end
    end
  end
end
