require 'yarr/query'

module Yarr
  # Generic base class for command handling
  class Command
    # Responds to a command received
    # @param ast The parsed AST of a command target
    def handle(ast)
      raise NotImplementedError
    end
  end

  # Gets the first key out of the AST and replies with it, underscores
  # translated to spaces.
  class WhatIsCommand < Command
    # Takes an AST and returns the response.
    def handle(ast)
      "It's a(n) #{ast.first.first}.".tr '_', ' '
    end
  end

  # Generic base class for commands that require database access.
  class QueryCommand < Command
    # @param query_adaptor {Yarr::Query}
    def initialize(query_adaptor = Query)
      @query_adaptor = query_adaptor
    end

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

  # &ri command handler. Looks up documentation link for the target.
  class RiCommand < QueryCommand
    private

    def handle_instance_method
      handle_call('instance')
    end

    def handle_class_method
      handle_call('class')
    end

    def handle_class_name
      result = @query_adaptor.klass_query(@klass)

      response(count: result.count,
               url_lambda: -> { result.first[:url] },
               objects_string: "class #@klass")
    end

    def handle_method_name
      result = @query_adaptor.method_query(@method)

      response(count: result.count,
               url_lambda: -> { result.first[:url] },
               objects_string: "method #@method",
               advice: "Use &list #@method if you would like to see a list")
    end

    def handle_call(type)
      result = @query_adaptor.joined_query(klass: @klass,
                                           method: @method,
                                           flavour: type.to_s)

      response(count: result.count,
               url_lambda: -> { result.first[:url] },
               objects_string: "class #@klass #{type} method #@method")
    end

    def response(count:, url_lambda:, objects_string:, advice: nil)
      case count
      when 0 then "Found no entry that matches #{objects_string}."
      when 1 then "https://ruby-doc.org/core-2.5.1/#{url_lambda.call}"
      else
        [ "I found #{count} entries matching with #{objects_string}.",
          advice
        ].compact.join(' ')
      end
    end
  end

  # List command handler. Returns a matching list for the target.
  class ListCommand < QueryCommand
    private

    def handle_instance_method
      handle_call('instance', '#')
    end

    def handle_class_method
      handle_call('class', '.')
    end

    def handle_class_name
      result = @query_adaptor.klass_like_query(@klass)

      if result.count.zero?
        "I haven't found any entry that matches class #@klass"
      else
        result.map { |row| "#{row[:name]}" }.join(', ')
      end
    end

    def handle_method_name
      result = @query_adaptor.method_like_query(@method)

      if result.count.zero?
        "I haven't found any entry that matches method #@method"
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

    def handle_call(type, type_delimiter)
      result = @query_adaptor.joined_like_query(klass: @klass,
                                                method: @method,
                                                flavour: type.to_s)
      if result.count.zero?
        "I haven't found any entry that matches #{type} method #@method on class #@klass"
      else
        result.map do |row|
          "#{row[:class_name]}#{type_delimiter}#{row[:method_name]}"
        end.join(', ')
      end
    end
  end
end
