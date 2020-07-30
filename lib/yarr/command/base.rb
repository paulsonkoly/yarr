# frozen_string_literal: true

require 'yarr/no_irc'

module Yarr
  module Command
    # Generic base class for command handling.
    #
    # A command receives a parsed {AST} from the bot and responds with some
    # string to it.
    class Base
      # Creates a command that handles the parsed input
      # @param ast [Yarr:AST] the parsed input
      # @param irc [Cinch::Bot|Yarr::NoIRC] irc provider
      # @param user [Cinch::Bot|Yarr::NoIRC::User] message sender
      def initialize(ast:, irc: NoIRC, user: NoIRC::User.new)
        @ast = ast
        @irc = irc
        @user = user
      end

      # @!attribute [r] user
      #   @return [Cinch::User|Yarr::NoIRC::User] message sender
      attr_reader :user

      # @!attribute [r] irc
      #   @return [Cinch::Bot|Yarr::NoIRC] irc provider
      attr_reader :irc

      # @!attribute [r] ast
      #   @return [Yarr::AST] the handled ast structure
      attr_reader :ast

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(_ast)
        false
      end

      # Runs the command
      def handle
        "#{self.class} doesn't know how to handle #{ast}"
      end
    end
  end
end
