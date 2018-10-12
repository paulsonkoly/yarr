require 'yarr/command_dispatcher'
require 'yarr/message/parser'
require 'yarr/message/truncator'

# Responds to rdoc documentation queries with links and more.
module Yarr
  # Handles the incoming message string and returns a response string.
  class Bot
    include CommandDispatcher

    def initialize
      @parser = Message::Parser.new
    end

    # Replies to a message
    # @param message [String] incoming message (without command prefix)
    # @return [String] response string
    def reply_to(message)
      dispatch(message)
      return error_message if error?
      ast = @parser.parse(target)
      response = handler.handle(ast)
      stuff.prepend(' , ') unless stuff.empty?
      Message::Truncator.truncate(response) + Message::Truncator.truncate(stuff)
    end
  end
end
