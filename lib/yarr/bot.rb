# frozen_string_literal: true

require 'yarr/command'
require 'yarr/message/truncator'
require 'yarr/dependencies'

# Responds to rdoc documentation queries with links and more.
module Yarr
  # Handles the incoming message string and returns a response string.
  class Bot
    include Message::Truncator

    include Import[
      'irc',
      'parser.input.parse_error',
      input_parser: 'parser.input'
    ]

    # Replies to a message
    # @example
    #
    #   bot = Yarr::Bot.new
    #   bot.reply_to 'ri Array' # => "https://ruby-doc.org/core-2.5.1/Array.html"
    #   bot.reply_to 'ast ast' # => "{:command=>\"ast\", :method_name=>\"ast\"}"
    #
    # @param message [String] incoming message (without IRC command prefix)
    # @return [String] response string
    def reply_to(message)
      ast, stuff = parse_input(message)
      response = Command.for_ast(ast, irc).handle
      post_process(response, stuff)
    rescue parse_error => e
      e.report(message)
    end

    private

    def parse_input(message)
      ast = input_parser.parse(message.chomp)
      stuff = ast[:stuff] || ''
      [ast, stuff]
    end

    def post_process(response, stuff)
      if stuff.empty?
        response
      else
        user = irc.user_list.find(stuff)
        if user then user.nick + ': ' << response
        else response << ', ' << truncate(stuff)
        end
      end
    end
  end
end
