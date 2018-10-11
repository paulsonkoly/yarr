require 'parslet'
require 'yarr/message/parser'
require 'yarr/message/command_dispatcher'
require 'yarr/message/command'
require 'qo'

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
        ast = @ri_parser.parse(@target)
        send(dispatch_method, ast)
      end

      private

      def ri(ast)
        RiCommand.new.handle(ast)
      end

      def what_is(ast)
        WhatIsCommand.new.handle(ast)
      end

      def list(ast)
        ListCommand.new.handle(ast)
      end
    end
  end
end
