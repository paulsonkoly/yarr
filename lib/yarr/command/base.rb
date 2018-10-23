module Yarr
  module Command
    # Generic base class for command handling.
    #
    # Sub classes should implement +query+ and +response+.+query+ should send a
    # query to the DB, and response is supposed to process the result of that
    # query.
    class Base
      # @param ast The parsed AST of a command target
      def initialize(ast)
        @ast = ast
      end

      attr_reader :ast

      # Responds to a command received
      def handle
        response(query)
      end

      private

      def query
        raise NotImplementedError
      end

      def response
        raise NotImplementedError
      end

      def klass
        dig_deep(@ast, :class_name)
      end

      def method
        dig_deep(@ast, :method_name)
      end

      # :reek:FeatureEnvy Hash is stdlib class.
      # :reek:TooManyStatements
      def dig_deep(hash, key)
        return hash[key] if hash.key? key
        hash.values.select { |value| value.kind_of? Hash }.each do |value|
          candidate = dig_deep(value, key)
          return candidate if candidate
        end
        nil
      end
    end
  end
end
