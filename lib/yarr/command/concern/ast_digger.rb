# frozen_string_literal: true

module Yarr
  module Command
    module Concern
      # Extend with ASTDigger to gain a digger class method.
      # Diggers can be used to define deep accessors on AST
      module ASTDigger
        # Defines a new digger method
        # @param name [Symbol] name of the digger
        # @param ast_name [String] AST key
        # @param block [block] An optional transformation block applied to the
        #   digged value
        # @yieldparam value [Object] the value digged
        def digger(name, ast_name = name, &block)
          define_method(name) do
            @digger ||= {}

            @digger[name] ||=
              begin
                block = ->(value) { value } unless block_given?
                instance_exec(ast.dig_deep(ast_name), &block)
              end
          end
        end
      end
    end
  end
end
