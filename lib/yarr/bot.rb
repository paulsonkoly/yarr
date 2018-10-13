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
      command, target, stuff = split(message)
      ast = @parser.parse(target)

      handler = dispatch(command, ast)
      return error_message if error?

      response = handler.handle
      stuff.prepend(' ,') unless stuff.empty?

      truncate(response) + truncate(stuff)
    end
  end
end
