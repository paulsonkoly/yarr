require 'active_support/core_ext/string/filters'

module Yarr
  module Message
    # Truncates the given string to the predefined maximum size.
    module Truncator
      MAX_LENGTH = 160 # max message length. Flood protection.
      class << self

        def truncate(message)
          message.truncate(MAX_LENGTH, separator: ' ')
        end
      end
    end
  end
end
