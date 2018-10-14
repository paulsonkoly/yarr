require 'yarr/command'
require 'qo'

module Yarr
  # Dispatch logic for commands and command targets
  module CommandDispatcher
    attr_reader :error_message

    # :reek:TooManyStatements I prefer a flat dispatcher. Routing logic in one
    # place

    # @return the command handler for the incoming command / AST
    def dispatch(command, ast)
      @error = false

      case [command, ast]
      when Qo['what_is', Any]
        Yarr::Command::WhatIs.new(ast)

      when Qo['ri', imethod]
        Yarr::Command::RiInstanceMethod.new(ast)
      when Qo['ri', cmethod]
        Yarr::Command::RiClassMethod.new(ast)
      when Qo['ri', method_name]
        Yarr::Command::RiMethodName.new(ast)
      when Qo['ri', class_name]
        Yarr::Command::RiClassName.new(ast)

      when Qo['list', imethod]
        Yarr::Command::ListInstanceMethod.new(ast)
      when Qo['list', cmethod]
        Yarr::Command::ListClassMethod.new(ast)
      when Qo['list', method_name]
        Yarr::Command::ListMethodName.new(ast)
      when Qo['list', class_name]
        Yarr::Command::ListClassName.new(ast)

      else
        @error = true
        @error_message = "I did not understand command #{command}."
      end
    end

    # true if there was an error with command dispatch
    def error?
      @error
    end

    private

    def imethod
      Qo[instance_method: Any]
    end

    def cmethod
      Qo[class_method: Any]
    end

    def method_name
      Qo[method_name: Any]
    end

    def class_name
      Qo[class_name: Any]
    end
  end
end
