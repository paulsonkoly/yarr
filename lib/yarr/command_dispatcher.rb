require 'yarr/command'

module Yarr
  # Dispatch logic for commands and command targets
  module CommandDispatcher
    # @api private
    # Class we use to match incoming input. You can match the command, ast
    # combo like this:
    #
    # @example
    #
    #     case { command: 'hello', ast: { world: {} } }
    #     when Match['hello', :world] then 'match'
    #     else 'oops'
    #     end # => 'match'
    class Match
      # Creates a matcher for a case statement.
      def self.[](command, ast_top = Any)
        new(command, ast_top)
      end

      private

      Any = Object.new

      def initialize(command, ast_top = Any)
        @command = command
        @ast_top = ast_top
      end

      def ===(actual)
        @command == actual[:command] && (@ast_top == Any ||
          actual[:ast].key?(@ast_top))
      end
    end

    attr_reader :error_message

    # :reek:TooManyStatements I prefer a flat dispatcher. Routing logic in one
    # place

    # @return [Yarr::Command|nil] the command handler for the incoming command
    #                             / AST
    def dispatch(command, ast)
      case { command: command, ast: ast }
      when Match['what_is']
        Yarr::Command::WhatIs.new(ast)

      when Match['ri', :instance_method]
        Yarr::Command::RiInstanceMethod.new(ast)
      when Match['ri', :class_method]
        Yarr::Command::RiClassMethod.new(ast)
      when Match['ri', :method_name]
        Yarr::Command::RiMethodName.new(ast)
      when Match['ri', :class_name]
        Yarr::Command::RiClassName.new(ast)

      when Match['list', :instance_method]
        Yarr::Command::ListInstanceMethod.new(ast)
      when Match['list', :class_method]
        Yarr::Command::ListClassMethod.new(ast)
      when Match['list', :method_name]
        Yarr::Command::ListMethodName.new(ast)
      when Match['list', :class_name]
        Yarr::Command::ListClassName.new(ast)

      else
        @error_message = "I did not understand command #{command}."
        nil
      end
    end
  end
end
