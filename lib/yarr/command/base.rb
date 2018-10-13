module Yarr
  module Command
    # Generic base class for command handling
    class Base
      # @param ast The parsed AST of a command target
      def initialize(ast)
        @ast = ast
      end

      # Responds to a command received
      def handle
        raise NotImplementedError
      end

      private

      def klass
        dig_deep(@ast, :class_name)
      end

      def method
        dig_deep(@ast, :method_name)
      end

      def dig_deep(hash, key)
        return hash[key] if hash.key? key
        hash.values.select { |h| h.kind_of? Hash }.each do |h|
          candidate = dig_deep(h, key)
          return candidate if candidate
        end
        nil
      end
    end
  end
end
