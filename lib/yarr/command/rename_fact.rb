require 'yarr/command/base'
require 'yarr/query'
require 'yarr/command/concern/ast_digger'
require 'yarr/command/concern/authorize'
require 'yarr/command/concern/user'

module Yarr
  module Command
    # Renames an existing fact
    class RenameFact < Base
      extend Concern::ASTDigger
      prepend Concern::Authorize
      include Concern::User

      authorize_for role: :op

      digger :old_name
      digger :new_name

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast[:command] == 'fact' && ast[:sub_command] == 'rename'
      end

      # Runs the command
      def handle
        DB.transaction { Query::Fact.by_name(old_name).rename(new_name) }
      end
    end
  end
end
