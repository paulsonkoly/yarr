require 'yarr/message/command'

module Yarr
  module Message
    # Splits the incomming command into two halfs: the command and the target.
    # @todo probably this should handle the tailing stuff, and truncation.
    module CommandDispatcher
      attr_reader :error_message, :handler, :target

      # splits up the message and sets {handler} to the appropriate command
      # handler
      def dispatch(message)
        command, _, @target = message.partition(/\s+/)

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
