require 'yarr/command/ast'
require 'yarr/command/ri'
require 'yarr/command/list'

module Yarr
  # Handles the specific commands after dispatch
  module Command
    COMMANDS = [AST,
                RiInstanceMethod,
                RiClassMethod,
                RiMethodName,
                RiClassName,
                ListInstanceMethod,
                ListClassMethod,
                ListMethodName,
                ListClassName].freeze

    # @return [Yarr::Command] the command handler for the incoming command / AST
    def self.for_ast(ast)
      COMMANDS
        .find { |handler| handler.match?(ast) }
        .then { |handler| handler.new(ast) }
    end
  end
end
