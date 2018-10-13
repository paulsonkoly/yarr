module Yarr
  module Command
    # Generic base class for commands that require database access.
    class Query < Base
      # Takes the AST and based on its structure calls the appropriate sub
      # handler. Sub handlers have to be overriden to take specific action in
      # sub classes.
      def handle(ast)
        ast = stringify_hash_values(ast)

        case ast.keys
        when [:instance_method]
          @klass = ast[:instance_method][:class_name]
          @method = ast[:instance_method][:method_name]
          handle_instance_method

        when [:class_method] then
          @klass = ast[:class_method][:class_name]
          @method = ast[:class_method][:method_name]
          handle_class_method

        when [:method_name] then
          @method = ast[:method_name]
          handle_method_name

        when [:class_name] then
          @klass = ast[:class_name]
          handle_class_name
        end
      end

      private

      # TODO this shouldn't even be here
      def stringify_hash_values(hash)
        hash.transform_values do |value|
          case value
          when Hash then stringify_hash_values(value)
          else value.to_s
          end
        end
      end

      %i[handle_instance_method handle_class_method
         handle_class_name handle_method_name
      ].each do |sym|
        define_method(sym) { raise NotImplementedError }
      end
    end
  end
end
