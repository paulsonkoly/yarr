require 'yarr/message/query'

module Yarr
  module Message
    # Gets the first key out of the AST and replies with it, underscores
    # translated to spaces.
    class WhatIsCommand
      def handle(ast)
        "It's a(n) #{ast.first.first}.".tr '_', ' '
      end
    end

    class Command
      include Query

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

    class RiCommand < Command
      private

      def handle_instance_method
        result = joined_query(klass: @klass, method: @method, flavour: 'instance')

        if result.count == 1
          "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
        else
          "I found #{result.count} entries matching with class: #{@klass}, instance method: #{@method}"
        end
      end

      def handle_class_method
        result = joined_query(klass: @klass, method: @method, flavour: 'class')

        if result.count == 1
          "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
        else
          "I found #{result.count} entries matching with class: #{@klass}, class method: #{@method}"
        end
      end

      def handle_class_name
        result = klass_query(@klass)

        if result.count == 1
          "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
        else
          "I found #{result.count} entries matching with class: #{@klass}."
        end
      end

      def handle_method_name
        result = method_query(@method)

        case result.count
        when 0 then "Found no entry that matches method #{@method}"
        when 1 then "https://ruby-doc.org/core-2.5.1/#{result.first[:url]}"
        else
          "I found #{result.count} entries matching with method: #{@method}. Use &list #{@method} if you would like to see a list"
        end
      end
    end

    class ListCommand < Command
      private

      def handle_instance_method
        result = joined_like_query(
          klass: @klass,
          method: @method,
          flavour: 'instance')

        if result.count.zero?
          "I haven't found any entry that matches #{@klass}"
        else
          result.map do |row|
            "#{row[:class_name]}##{row[:method_name]}"
          end.join(', ')
        end
      end

      def handle_class_method
        result = joined_like_query(
          klass: @klass,
          method: @method,
          flavour: 'class')

        if result.count.zero?
          "I haven't found any entry that matches #{klass}"
        else
          result.map do |row|
            "#{row[:class_name]}.#{row[:method_name]}"
          end.join(', ')
        end
      end

      def handle_clas_name
        result = klass_like_query(@klass)

        if result.count.zero?
          "I haven't found any entry that matches #{@klass}"
        else
          result.map { |row| "#{row[:name]}" }.join(', ')
        end
      end

      def handle_method_name
        result = method_like_query(@method)

        if result.count.zero?
          "I haven't found any entry that matches #{@klass}"
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
