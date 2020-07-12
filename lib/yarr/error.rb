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

      super "parser error at position #{position} around `#{fail_char}'"
    end

    private

    def failure_cause
      @parslet_error.parse_failure_cause
    end

    def position
      failure_cause.pos.charpos
    end

    def fail_char
      @message[position]
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
