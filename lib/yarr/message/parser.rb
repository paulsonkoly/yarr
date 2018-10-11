require 'parslet'

module Yarr
  module Message
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
  end
end
