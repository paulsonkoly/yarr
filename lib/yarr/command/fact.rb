# frozen_string_literal: true

require 'yarr/command/base'
require 'yarr/query'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # Showing factoids by name
    class Fact < Base
      extend Concern::ASTDigger

      digger :name

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast[:command] == 'fact' && !ast.key?(:sub_command)
      end

      # Runs the command
      def handle
        factoid.increment_count
        factoid.content
      end

      private

      def factoid
        @factoid ||= Query::Fact.by_name(name)
      end
    end
  end
end
