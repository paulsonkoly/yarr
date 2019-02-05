require 'faker'
require 'yarr/command/base'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # Exposing the faker gem as a bot command
    class Fake < Base
      extend Concern::ASTDigger
      digger :klass, :class_name
      digger :method, :method_name

      def self.match?(ast)
        ast[:command] == 'fake' && ast.key?(:class_method)
      end

      def handle
        Faker.const_get(klass).send(method).to_s
      rescue NameError
        'No suitable faker found. The list is at ' \
        'https://github.com/stympy/faker with the restriction that I need ' \
        'Classname.methodname.'
      end
    end
  end
end