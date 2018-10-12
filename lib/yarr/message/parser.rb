require 'parslet'

module Yarr
  module Message
    # A parslet parser that parses RDoc notation ruby tokens. We can parse:
    # method names, class names, instance method calls, class method calls.
    #
    # @example
    #
    #   p = Yarr::Message::Parser.new
    #   p.parse 'a' # => {:method_name=>"a"@0}
    #   p.parse 'B' # => {:class_name=>"B"@0}
    #   p.parse 'A#b' # => {:instance_method=>{:class_name=>"A"@0, :method_name=>"b"@2}}
    #   p.parse 'A.b' # => {:class_method=>{:class_name=>"A"@0, :method_name=>"b"@2}}
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

      rule(:method) { (match('[a-z_!?+\-*/%]').repeat(1)).as(:method_name) }

      root(:expression)
    end
  end
end
