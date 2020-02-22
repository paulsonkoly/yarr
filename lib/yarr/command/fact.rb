require 'yarr/command/base'
require 'yarr/query'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # Exposing the faker gem as a bot command
    class Fact < Base
      extend Concern::ASTDigger

      digger :name

      # Null object for not finding a factoid
      class NoFactoid
        # @param name [String] factoid name
        def initialize(name)
          @name = name
        end

        # @see {Yarr::Query::Fact#increment_count}
        def increment_count; end

        # @see {Yarr::Query::Fact#content}
        def content
          "I don't know anything about #{@name}."
        end
      end
      private_constant :NoFactoid

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ['fact', '?'].member? ast[:command]
      end

      # Runs the command
      def handle
        factoid.increment_count
        factoid.content
      end

      private

      def factoid
        @factoid ||= Query::Fact[name: name] || NoFactoid.new(name)
      end
    end
  end
end
