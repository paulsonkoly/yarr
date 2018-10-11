require 'parslet'
require 'yarr/message/parser'
require 'yarr/message/command_dispatcher'
require 'yarr/message/command'
require 'qo'

module Yarr
  module Message
    

    class Message
      include CommandDispatcher
      include Query

      def initialize
        @ri_parser = Parser.new
      end

      def reply_to(message)
        dispatch(message)
        return error_message if error?
        ast = @ri_parser.parse(@target)
        send(dispatch_method, ast)
      end

      private

      def ri(ast)
        RiCommand.new.handle(ast)
      end

      def what_is(ast)
        WhatIsCommand.new.handle(ast)
      end

      def list(ast)
        case ast
        when Qo[instance_method: Any]
          klass = ast[:instance_method][:class_name].to_s
          method = ast[:instance_method][:method_name].to_s

          result = joined_like_query(
            klass: klass,
            method: method,
            flavour: 'instance')

          if result.count.zero?
            "I haven't found any entry that matches #{klass}"
          else
            result.map do |row|
              "#{row[:class_name]}##{row[:method_name]}"
            end.join(', ')
          end

        when Qo[class_method: Any]
          klass = ast[:class_method][:class_name].to_s
          method = ast[:class_method][:method_name].to_s

          result = joined_like_query(
            klass: klass,
            method: method,
            flavour: 'class')

          if result.count.zero?
            "I haven't found any entry that matches #{klass}"
          else
            result.map do |row|
              "#{row[:class_name]}.#{row[:method_name]}"
            end.join(', ')
          end

        when Qo[class_name: Any]
          klass = ast[:class_name].to_s

          result = klass_like_query(klass)

          if result.count.zero?
            "I haven't found any entry that matches #{klass}"
          else
            result.map { |row| "#{row[:name]}" }.join(', ')
          end

        when Qo[method_name: Any]
          method = ast[:method_name].to_s

          result = method_like_query(method)

          if result.count.zero?
            "I haven't found any entry that matches #{klass}"
          else
            result.map do |row|
              flavour = case row[:method_flavour]
                        when 'instance' then '#'
                        when 'class' then '.'
                        else '???'
                        end
              "#{row[:class_name]}#{flavour}#{row[:method_name]}"
            end.join(', ')
          end
        end
      end
    end
  end
end
