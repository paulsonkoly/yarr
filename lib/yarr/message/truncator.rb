module Yarr
  module Message
    # Flood protection.
    module Truncator
      MAX_LENGTH = 160 # max message length.
      OMISSION = '...' # use ... if truncated
      SEPARATOR = ' '  # natural break point

      # :reek:UtilityFunction

      # Truncates the given string to the predefined maximum size.
      def truncate(message, omission = OMISSION)
        message = message.lines.first.strip

        return message if message.length <= MAX_LENGTH

        split_length = MAX_LENGTH - omission.length
        split_point = message.rindex(SEPARATOR, split_length) || split_length

        "#{message[0, split_point]}#{omission}"
      end
    end
  end
end
