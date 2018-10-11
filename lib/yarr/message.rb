require 'parslet'
require 'yarr/message/parser'
require 'yarr/message/command_dispatcher'
require 'yarr/message/command'

module Yarr
  module Message
    class Message
      include CommandDispatcher

      def initialize
        @ri_parser = Parser.new
      end

      def reply_to(message)
        dispatch(message)
        return error_message if error?
        ast = @ri_parser.parse(target)
        handler.handle(ast)
      end
    end
  end
end
