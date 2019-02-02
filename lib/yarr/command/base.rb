module Yarr
  module Command
    # Generic base class for command handling.
    #
    # A command receives a parsed AST from the bot and responds with some
    # string to it.
    class Base
      # @param ast The parsed AST of a command target
      def initialize(ast)
        @ast = ast
      end

      attr_reader :ast

      private

      def self.digger(name, ast_name = :"#{name}_name")
        define_method(name) { dig_deep(@ast, ast_name) }
      end
      private_class_method :digger

      digger :klass, :class_name
      digger :method
      digger :origin

      # :reek:FeatureEnvy Hash is stdlib class.
      # :reek:TooManyStatements
      def dig_deep(hash, key)
        return hash[key] if hash.key? key

        hash.values.select { |value| value.is_a? Hash }.each do |value|
          candidate = dig_deep(value, key)
          return candidate if candidate
        end
        nil
      end
    end
  end
end
