module Yarr
  module Message
    # Flood protection.
    module Truncator
      MAX_LENGTH = 160 # max message length.
      OMISSION = '...' # use ... if truncated
      SEPARATOR = ' '  # natural break point

      # :reek:UtilityFunction

      # Truncates the given string to the predefined maximum size.
      # @param omission [String] The string that indiciates the message was
      #                          truncated
      # @param max_length [Integer] the maximum length after truncation
      def truncate(message, omission: OMISSION, max_length: MAX_LENGTH)
        message = message.lines.first.strip

        return message if message.length <= max_length

        split_length = max_length - omission.length
        split_point = message.rindex(SEPARATOR, split_length) || split_length

        "#{message[0, split_point]}#{omission}"
      end
    end
  end
end
