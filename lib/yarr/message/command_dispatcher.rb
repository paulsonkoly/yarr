require 'yarr/message/command'

module Yarr
  module Message
    # Splits the incomming command into the following sections:
    #   - command (like 'list')
    #   - command target (like 'Array')
    #   - stuff (anything precedded by a ',')
    module CommandDispatcher
      # @!attribute [r] handler
      #   @return the command handler, {Yarr::Message::Command}
      attr_reader :error_message, :handler, :target, :stuff

      # splits up the message and sets {handler} to the appropriate command
      # handler
      def dispatch(message)
        command, _, rest = message.chomp.partition(/\s+/)
        @target, _, @stuff = rest.partition(',')

        if %w[ri list what_is].include? command
          command = command.split('_').map(&:capitalize).join
          @handler = Yarr::Message.const_get("#{command}Command").new
          @error = false
        else
          @error = true
          @error_message = "I did not understand command #{command}."
        end
      end

      # true if there was an error with command dispatch
      def error?
        @error
      end
    end
  end
end
