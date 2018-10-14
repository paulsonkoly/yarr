require 'active_support/core_ext/string/filters'

module Yarr
  module Message
    # Flood protection.
    module Truncator
      MAX_LENGTH = 160 # max message length.

      # :reek:UtilityFunction

      # Truncates the given string to the predefined maximum size.
      def truncate(message)
        message.truncate(MAX_LENGTH, separator: ' ')
      end
    end
  end
end
