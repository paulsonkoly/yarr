module Yarr
  module Command
    module Concern
      # Extend with ASTDigger to gain a digger class method.
      # Diggers can be used to define deep accessors on AST
      module ASTDigger
        # Defines a new digger method
        # @param name [Symbol] name of the digger
        # @param ast_name [String] AST key
        def digger(name, ast_name = :"#{name}_name")
          define_method(name) { ast.dig_deep(ast_name) }
        end
      end
    end
  end
end
