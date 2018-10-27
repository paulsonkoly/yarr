module Yarr
  module Message
    # Flood protection.
    module Truncator
      MAX_LENGTH = 160 # max message length.
      OMISSION = '...' # use ... if truncated
      SEPARATOR = ' '  # natural break point

      # :reek:UtilityFunction

      # Truncates the given string to the predefined maximum size.
      def truncate(message)
        return message if message.length <= MAX_LENGTH

        split_length = MAX_LENGTH - OMISSION.length
        split_point = message.rindex(SEPARATOR, split_length) || 0

        "#{message[0, split_point]}#{OMISSION}"
      end
    end
  end
end
