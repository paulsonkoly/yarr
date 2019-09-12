module Yarr
  module Command
    # evaluates the content fetched from a url on an online evaluator service
    # like carc.in
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
