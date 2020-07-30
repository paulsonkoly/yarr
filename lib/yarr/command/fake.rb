# frozen_string_literal: true

require 'faker'
require 'yarr/command/base'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # Exposing the faker gem as a bot command
    class Fake < Base
      extend Concern::ASTDigger
      digger :class_name
      digger :method_name

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast[:command] == 'fake' && ast.key?(:class_method)
      end

      # Runs the command
      def handle
        Faker.const_get(class_name).send(method_name).to_s
      rescue NameError
        'No suitable faker found. The list is at ' \
        'https://github.com/stympy/faker with the restriction that I need ' \
        'Classname.methodname.'
      end
    end
  end
end
