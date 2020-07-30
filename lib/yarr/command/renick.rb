# frozen_string_literal: true

module Yarr
  module Command
    # Resets the bot's nick
    class Renick < Base
      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast[:command] == 'renick'
      end

      # Runs the command
      def handle
        irc.nick = Yarr::CONFIG.nick
        'okay'
      end
    end
  end
end
