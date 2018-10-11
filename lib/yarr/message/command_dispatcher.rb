require 'yarr/message/command'

module Yarr
  module Message
    # Splits the incomming command into two halfs: the command and the target.
    module CommandDispatcher
      attr_reader :error_message, :handler, :target

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

      def error?
        @error
      end
    end
  end
end
