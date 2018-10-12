require 'yarr/message/parser'
require 'yarr/message/command_dispatcher'
require 'yarr/message/command'
require 'yarr/message/truncator'

# Responds to rdoc documentation queries with links and more.
module Yarr
  # Handles the incoming message string and returns a response string.
  module Message
    # Handles the incoming message string and returns a response string.
    class Message
      include CommandDispatcher

      def initialize
        @ri_parser = Parser.new
      end

      # Replies to a message
      # @param message [String] incoming message (without command prefix)
      # @return [String] response string
      def reply_to(message)
        dispatch(message)
        return error_message if error?
        ast = @ri_parser.parse(target)
        response = handler.handle(ast)
        stuff.prepend(' , ') unless stuff.empty?
        Truncator.truncate(response) + Truncator.truncate(stuff)
      end
    end
  end
end
