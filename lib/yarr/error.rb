module Yarr
  # Generic error class for all Yarr errors
  Error = Class.new(StandardError)

  # Error raised when parsing fails
  class ParseError < Error
    # Initialize parse error
    # @param parslet_error [Parslet::ParseFailed] the Parslet error
    # @param message [String] the original bot message
    def initialize(parslet_error, message)
      @parslet_error = parslet_error
      @message = message
      puts failure_cause.ascii_tree if Yarr::CONFIG.development?

      super end_user_message
    end

    private

    def failure_cause
      @parslet_error.parse_failure_cause
    end

    def furthest_parse
      furthest_parse = failure_cause
      loop do
        children = furthest_parse.children
        return furthest_parse if children.empty?

        furthest_parse = children.max_by(&:pos)
      end
    end

    def position
      furthest_parse.pos.charpos
    end

    def failure
      furthest_parse.message
    end

    def fail_char
      @message[position]
    end

    def end_user_message
      "parser error #{failure} at position #{position} around `#{fail_char}'"
    end
  end

  # Raised when current user does not have privileges
  class AuthorizationError < Error
    # @param user [String] nick of the user
    # @param role [Symbol] role to authorize for
    def initialize(user, role)
      @user = user
      @role = role

      super "#{user.nick} is not authorized to execute command as #{role}"
    end
  end

  # error in the config/yarr.yml file
  class ConfigFileError < Error
  end

  # when there is no answer or mulitple answers
  class AnswerAmbiguityError < Error
  end
end
