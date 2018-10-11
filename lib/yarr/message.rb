require 'parslet'
require 'qo'

module Yarr
  module Message
    # Splits the incomming command into two halfs: the command and the arguments.
    module CommandDispatcher
      attr_reader :error_message, :dispatch_method, :target

      def dispatch(message)
        command, _, @target = message.partition(/\s+/)

        if %w[ri list what_is].include? command
          @dispatch_method = command.to_sym
          @error = false
        else
          @error = true
          @error_message = "I did not understand command #{command}."
        end
      end

      def error?
        @error
      end
    end

    module Query
      def joined_query(method:, klass:, flavour:)
        DB[:classes]
          .join(:methods, class_id: :id)
          .where(Sequel[:methods][:name] => method,
                 Sequel[:classes][:name] => klass,
                 Sequel[:methods][:flavour] => flavour)
      end

      def klass_query(klass)
        DB[:classes].where(name: klass)
      end

      def method_query(method)
        DB[:methods].where(name: method)
      end

      def joined_like_query(method:, klass:, flavour:)
        DB[:classes]
          .join(:methods, class_id: :id)
          .select(Sequel[:methods][:name].as(:method_name),
        Sequel[:classes][:name].as(:class_name))
          .where(Sequel[:methods][:name].like(method) &
        Sequel[:classes][:name].like(klass) &
        { Sequel[:methods][:flavour] => flavour })
      end

      def klass_like_query(klass)
        Yarr::DB[:classes].where(Sequel[:name].like(klass))
      end

      def method_like_query(klass:, method:)
        Yarr::DB[:classes]
          .join(:methods, class_id: :id)
          .select(Sequel[:methods][:name].as(:method_name),
                  Sequel[:classes][:name].as(:class_name),
                  Sequel[:methods][:flavour].as(:method_flavour))
          .where(Sequel[:methods][:name].like(method))
      end
    end

    class Parser < Parslet::Parser
      rule(:query) do
        expression >> str(',') >> str(' ').repeat >> stuff |
          expression
      end

      rule(:expression) do
        instance_method.as(:instance_method) |
          class_method.as(:class_method) |
          method |
          klass
      end

      rule(:instance_method) { klass >> str('#') >> method }

      rule(:class_method) { klass >> str('.') >> method }

      rule(:klass) do
        (match('[A-Z%]') >> match('[a-zA-Z:%]').repeat).as(:class_name)
      end

      rule(:method) { (match('[a-z_!?+\-*/%]').repeat(1)).as(:method_name) }

      rule(:stuff) { (any.repeat).as(:stuff) }

      root(:query)
    end

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
        case ast
        when Qo[instance_method: Any]
          klass = ast[:instance_method][:class_name].to_s
          method = ast[:instance_method][:method_name].to_s

          result = joined_query(klass: klass, method: method, flavour: 'instance')

          if result.count == 1
            "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
          else
            "I found #{result.count} entries matching with class: #{klass}, instance method: #{method}"
          end

        when Qo[class_method: Any]
          klass = ast[:class_method][:class_name].to_s
          method = ast[:class_method][:method_name].to_s

          result = joined_query(klass: klass, method: method, flavour: 'class')

          if result.count == 1
            "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
          else
            "I found #{result.count} entries matching with class: #{klass}, class method: #{method}"
          end

        when Qo[class_name: Any]
          klass = ast[:class_name].to_s

          result = klass_query(klass) # yeah. I know

          if result.count == 1
            "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
          else
            "I found #{result.count} entries matching with class: #{klass}."
          end

        when Qo[method_name: Any]
          method = ast[:method_name].to_s

          result = method_query(method)

          case result.count
          when 0 then "Found no entry that matches method #{method}"
          when 1 then "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
          else
            "I found #{result.count} entries matching with method: #{method}. Use &list #{method} if you would like to see a list"
          end
        end
      end

      def what_is(ast)
        "It's a(n) #{ast.first.first}.".tr '_', ' '
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
