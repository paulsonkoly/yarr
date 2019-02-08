require 'yarr/command'
require 'yarr/input_parser'
require 'yarr/message/truncator'
require 'yarr/no_irc'

# Responds to rdoc documentation queries with links and more.
module Yarr
  # Handles the incoming message string and returns a response string.
  class Bot
    include Message::Truncator

    # @param irc_provider [Cinch::Bot] IRC functionality provider.
    def initialize(irc_provider = NoIRC)
      @parser = InputParser.new
      @irc = irc_provider
    end

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
      response = Command.for_ast(ast).handle
      post_process(response, stuff)
    rescue InputParser::ParseError => error
      error.report
    end

    private

    def parse_input(message)
      ast = @parser.parse(message.chomp)
      stuff = ast[:stuff] || ''
      [ast, stuff]
    end

    def post_process(response, stuff)
      response = truncate(response)
      if stuff.empty?
        response
      else
        user = @irc.user_list.find(stuff)
        if user then user.nick + ': ' << response
        else response << ', ' << truncate(stuff)
        end
      end
    end
  end
end
