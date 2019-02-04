require 'yarr/command/ast'
require 'yarr/command/ri'
require 'yarr/command/list'
require 'yarr/command/null'

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
      # TODO change to .then once we migrated to 2.6
      COMMANDS
        .find(-> { Null }) { |handler| handler.match?(ast) }
        .yield_self { |handler| handler.new(ast) }
    end
  end
end
