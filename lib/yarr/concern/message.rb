# frozen_string_literal: true

module Yarr
  # Message related helper methods
  module Message
    def nick_prefix(user, message)
      return message unless user.online?

      "#{user.nick}: #{message}"
    end

    module_function :nick_prefix
  end
end
