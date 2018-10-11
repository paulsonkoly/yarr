module Yarr
  module Message
    # Splits the incomming command into two halfs: the command and the target.
    module CommandDispatcher
      attr_reader :error_message, :dispatch_method, :target

      def dispatch(message)
        command, _, @target = message.partition(/\s+/)

        if %w[ri list what_is].include? command
          @dispatch_method = command.to_sym
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
