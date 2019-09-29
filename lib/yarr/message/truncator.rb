module Yarr
  module Message
    # Flood protection.
    module Truncator
      MAX_LENGTH = 160 # max message length.
      OMISSION = '...'.freeze # use ... if truncated
      SEPARATOR = ' '.freeze  # natural break point

      # Truncates the given string to the predefined maximum size.
      # @param message [String] the string to truncate
      # @param omission [String] The string that indicates the message was
      #   truncated
      # @param suffix [String] a suffix that's always appended after the string
      #   regardless of whether it was truncated or not. The truncation length
      #   however takes it into account.
      # @return [String] the truncated message
      # @example
      #   Truncator.truncate('Lorem ipsum dolor sit amet, consectetur' \
      #                      ' adipisicing elit, sed do eiusmod tempor' \
      #                      ' incididunt ut labore et dolore magna aliqua.' \
      #                      ' Ut enim ad minim veniam, quis nostrud' \
      #                      ' exercitation ullamco laboris nisi ut aliquip ' \
      #                      ' ex ea commodo consequat. Duis aute irure ' \
      #                      ' dolor in reprehenderit in voluptate velit ' \
      #                      ' esse cillum dolore eu fugiat nulla pariatur. ' \
      #                      ' Excepteur sint occaecat cupidatat non ' \
      #                      ' proident, sunt in culpa qui officia deserunt' \
      #                      ' mollit anim id est laborum.')
      #   # => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed" \
      #   # "do eiusmod tempor incididunt ut labore et dolore magna aliqua." \
      #   # "Ut enim ad minim veniam, quis..."
      def truncate(message,
                   omission: OMISSION,
                   suffix: '')
        multiline = message.lines.count > 1
        message = message.lines.first.strip
        suffixed = message + suffix
        return suffixed if suffixed.length <= MAX_LENGTH && ! multiline

        split_point = split_point(message, omission, suffix)
        "#{message[0, split_point]}#{omission}#{suffix}"
      end

      module_function :truncate

      private

      # @api private
      def split_point(message, omission, suffix)
        split_length = MAX_LENGTH - omission.length - suffix.length
        # If the message doesn't end with separator but shorter than allowed
        # length we don't want to chop of the last section of it
        message += SEPARATOR
        message.rindex(SEPARATOR, split_length) || split_length
      end

      module_function :split_point
    end
  end
end
