require 'yarr/command/base'
require 'yarr/query'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # Exposing the faker gem as a bot command
    class Fact < Base
      extend Concern::ASTDigger

      digger :name

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ['fact', '?'].member? ast[:command]
      end

      # Runs the command
      def handle
        Query::Fact[name: name].content
      rescue NoMethodError
        no_factoid_response
      end

      private

      def no_factoid_response
        "I don't know anything about #{name}."
      end
    end
  end
end
