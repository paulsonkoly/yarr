require 'yarr/command'
require 'qo'

module Yarr
  module CommandDispatcher
    attr_reader :error_message

    # @return the command handler for the incoming command / AST
    def dispatch(command, ast)
      @error = false

      case [command, ast]
      when Qo['what_is', Any]
        Yarr::Command::WhatIs.new(ast)

      when Qo['ri', Qo[instance_method: Any]]
        Yarr::Command::RiInstanceMethod.new(ast)
      when Qo['ri', Qo[class_method: Any]]
        Yarr::Command::RiClassMethod.new(ast)
      when Qo['ri', Qo[method_name: Any]]
        Yarr::Command::RiMethodName.new(ast)
      when Qo['ri', Qo[class_name: Any]]
        Yarr::Command::RiClassName.new(ast)

      when Qo['list', Qo[instance_method: Any]]
        Yarr::Command::ListInstanceMethod.new(ast)
      when Qo['list', Qo[class_method: Any]]
        Yarr::Command::ListClassMethod.new(ast)
      when Qo['list', Qo[method_name: Any]]
        Yarr::Command::ListMethodName.new(ast)
      when Qo['list', Qo[class_name: Any]]
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
  end
end
