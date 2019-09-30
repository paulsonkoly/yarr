module Yarr
  module Command
    # Resets the bot's nick
    class Renick < Base
      def self.match?(ast)
        ast[:command] == 'renick'
      end

      def handle
        irc.nick = Yarr.config.nick
        'okay'
      end
    end
  end
end
