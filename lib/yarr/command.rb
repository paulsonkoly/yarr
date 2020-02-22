files = Dir[File.join(File.dirname(__FILE__), 'command', '*.rb')].sort
files.each { |command_src| require command_src }

module Yarr
  # Handles the specific commands after dispatch
  module Command
    # Commands {for_ast} can dispatch to.
    COMMANDS = ObjectSpace.each_object(Class).select do |subclass|
      subclass.ancestors.include? Base
    end

    # Selects the appropriate handler for the AST
    #
    # When no appropriate handler found it returns a {Base} command.
    # @param ast [Yarr::AST] the parsed AST structure
    # @param irc [Cinch::Bot|Yarr::NoIRC] irc provider
    # @return [Yarr::Command] the command handler for the incoming command / AST
    # @example
    #   ast = AST.new(command: 'ri', method_name: 'method')
    #   Command.for_ast(ast).class # => Yarr::Command::RiMethodName
    def self.for_ast(ast, irc = NoIRC)
      COMMANDS
        .find(-> { Base }) { |handler| handler.match?(ast) }
        .new(ast: ast, irc: irc)
    end
  end
end
