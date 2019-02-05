require 'faker'
require 'yarr/command/base'

module Yarr
  module Command
    # Exposing the faker gem as a bot command
    class Fake < Base
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
