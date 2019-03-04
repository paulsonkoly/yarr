require 'yarr/command/base'
require 'yarr/command/ri'
require 'yarr/command/list'
require 'yarr/command/fake'
require 'yarr/command/evaluate'
require 'yarr/command/url_evaluate'

module Yarr
  # Handles the specific commands after dispatch
  module Command
    # Commands {for_ast} can dispatch to.
    COMMANDS = [RiInstanceMethod,
                RiClassMethod,
                RiMethodName,
                RiClassName,
                ListInstanceMethod,
                ListClassMethod,
                ListMethodName,
                ListClassName,
                Fake,
                Evaluate,
                URLEvaluate].freeze

    # Selects the appropriate handler for the AST
    #
    # When no appropriate handler found it returns a {Base} command.
    # @param ast [Yarr::AST] the parsed AST structure
    # @return [Yarr::Command] the command handler for the incoming command / AST
    # @example
    #   ast = AST.new(command: 'ri', method_name: 'method')
    #   Command.for_ast(ast).class # => Yarr::Command::RiMethodName
    def self.for_ast(ast)
      COMMANDS
        .find(-> { Base }) { |handler| handler.match?(ast) }
        .new(ast)
    end
  end
end
