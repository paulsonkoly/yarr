require 'yarr/command'

module Yarr
  # Dispatch logic for commands and command targets
  module CommandDispatcher
    # @api private
    # Class we use to match the AST.
    #
    # @example
    #
    #     case { command: 'hello', class_name: 'Blah' }
    #     when Match['hello', :class_name] then 'match'
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
        @command == actual[:command] &&
          (@ast_top == Any || actual.key?(@ast_top))
      end
    end

    # :reek:TooManyStatements I prefer a flat dispatcher. Routing logic in one
    # place
    # :reek:UtilityFunction

    # @return [Yarr::Command|nil] the command handler for the incoming command
    #                             / AST
    def dispatch(ast)
      case ast
      when Match['ast']
        Command::AST.new(ast)

      when Match['ri', :instance_method]
        Command::RiInstanceMethod.new(ast)
      when Match['ri', :class_method]
        Command::RiClassMethod.new(ast)
      when Match['ri', :method_name]
        Command::RiMethodName.new(ast)
      when Match['ri', :class_name]
        Command::RiClassName.new(ast)

      when Match['list', :instance_method]
        Command::ListInstanceMethod.new(ast)
      when Match['list', :class_method]
        Command::ListClassMethod.new(ast)
      when Match['list', :method_name]
        Command::ListMethodName.new(ast)
      when Match['list', :class_name]
        Command::ListClassName.new(ast)
      end
    end
  end
end
