module Yarr
  module Message
    # Flood protection.
    module Truncator
      MAX_LENGTH = 160 # max message length.
      OMISSION = '...'.freeze # use ... if truncated
      SEPARATOR = ' '.freeze  # natural break point

      # Truncates the given string to the predefined maximum size.
      # @param omission [String] The string that indiciates the message was
      #   truncated
      # @param suffix [String] a suffix that's always appended after the string
      #   regardless of whether it was truncated or not. The truncation length
      #   however takes it into account.
      def truncate(message,
                   omission: OMISSION,
                   suffix: '')
        message = message.lines.first.strip
        suffixed = message + suffix
        return suffixed if suffixed.length <= MAX_LENGTH

        split_point = split_point(message, omission, suffix)
        "#{message[0, split_point]}#{omission}#{suffix}"
      end

      module_function :truncate

      private

      def split_point(message, omission, suffix)
        split_length = MAX_LENGTH - omission.length - suffix.length
        message.rindex(SEPARATOR, split_length) || split_length
      end

      module_function :split_point
    end
  end
end
