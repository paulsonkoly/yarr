require 'parslet'

module Yarr
  # Code dealing with the subject (aka. target) part of the bot's command. See
  # {Parser} for a list of what we can handle.
  module Message
    # A parslet parser that parses RDoc notation ruby tokens. We can parse:
    # method names, class names, instance method calls, class method calls.
    #
    # @example
    #
    #   p = Yarr::Message::Parser.new
    #   p.parse 'a' # => {:method_name=>"a"}
    #   p.parse 'B' # => {:class_name=>"B"}
    #   p.parse 'A#b' # => {:instance_method=>{:class_name=>"A", :method_name=>"b"}}
    #   p.parse 'A.b' # => {:class_method=>{:class_name=>"A", :method_name=>"b"}}
    #
    # @note We also accept % character anywhere to support like queries.
    class Parser < Parslet::Parser
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

      rule(:method) { (match('[a-z_!?=+\-*/%]').repeat(1)).as(:method_name) }

      root(:expression)

      # Same as Parslet::Parser#parse, except we return string hash values
      # @param string [String] the input to parse
      # @return [Hash] AST
      def parse(string)
        stringify_hash_values(super)
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
    end
  end
end
