module Yarr
  # Null object for no IRC connection
  module NoIRC
    # @return [#find] empty user list
    def self.user_list
      []
    end

    # Accepts setting the nick, but being a null-object does nothing
    def self.nick=(*); end

    # falsey value, real IRC adaptor is expected to respond with a truthy value
    # @return [FalseClass] false
    def self.irc
      false
    end

    # Null object user for no irc connection
    class User
      # @return [String] 'no user'
      def nick
        'no user'
      end

      # @return [String] 'console'
      def host_unsynced
        ''
      end

      # @return [FalseClass] false
      def online?
        false
      end
    end
  end
end
