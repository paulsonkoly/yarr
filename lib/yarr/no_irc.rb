module Yarr
  # Null object for no IRC connection
  module NoIRC
    # @return [#find] empty user list
    def self.user_list
      []
    end

    # Accepts setting the nick, but being a null-object does nothing
    def self.nick=(*); end
  end
end
