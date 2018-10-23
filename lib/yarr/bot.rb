require 'yarr/command_dispatcher'
require 'yarr/input_parser'
require 'yarr/message/truncator'
require 'yarr/configuration'

# Responds to rdoc documentation queries with links and more.
module Yarr
  # Handles the incoming message string and returns a response string.
  class Bot
    include CommandDispatcher
    include Message::Truncator

    def initialize
      @parser = InputParser.new
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
      begin
        ast, stuff = parse_input(message)
        response = dispatch(ast).handle
        post_process(response, stuff)

      rescue Parslet::ParseFailed => error
        handle_error(error)
      end
    end

    private

    def parse_input(message)
      ast = @parser.parse(message.chomp)
      stuff = ast[:stuff] || ''
      [ast, stuff]
    end

    def post_process(response, stuff)
      stuff.prepend(' ,') unless stuff.empty?
      truncate(response) + truncate(stuff)
    end

    # :reek:FeatureEnvy

    def handle_error(error)
      cause = error.parse_failure_cause
      puts cause.ascii_tree if Yarr.config.development?
      "did not understand that, parser error @ char position #{cause.pos.charpos}"
    end
  end
end
