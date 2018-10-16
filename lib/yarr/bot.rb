require 'yarr/command_dispatcher'
require 'yarr/message/parser'
require 'yarr/message/truncator'
require 'yarr/message/splitter'

# Responds to rdoc documentation queries with links and more.
module Yarr
  # Handles the incoming message string and returns a response string.
  class Bot
    include CommandDispatcher
    include Message::Splitter
    include Message::Truncator

    def initialize
      @parser = Message::Parser.new
    end

    # Replies to a message
    # @param message [String] incoming message (without command prefix)
    # @return [String] response string
    def reply_to(message)
      (command, ast, stuff = parse_input(message)) or return error_message

      handler = dispatch(command, ast) or return error_message

      response = handler.handle

      post_process(response, stuff)
    end

    private

    def parse_input(message)
      begin
        command, target, stuff = split(message)
        ast = @parser.parse(target)
        [command, ast, stuff]
      rescue Parslet::ParseFailed
        @error_message = 'did not understand command the command target'
        nil
      end
    end

    def post_process(response, stuff)
      stuff.prepend(' ,') unless stuff.empty?
      truncate(response) + truncate(stuff)
    end
  end
end
