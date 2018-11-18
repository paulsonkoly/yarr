require 'parslet'

module Yarr
  # Code parsing the user input. The user input contains 3 sections, 2
  # required and 1 optional. The sesctions are separated by white spaces.
  # Between the second and third section an optional comma is allowed.
  # A usual user input might look like:
  #
  #    list Array phaul
  #    ri Set, phaul
  #
  # - The first word +list+ is the command.
  # - The second part is until the next `,', whitespace, or til the end:
  #   +Array+. This part is the command target.
  # - The third part is optional: +phaul+. The code refers to this part as
  #   "stuff" and it's copied straight to the output, or in case if it's a
  #   nick, we prefix our response with it.
  #
  # The target portion of the user input is ri notation ruby token. (Normal
  # Ruby token except # is used for instance methods.)
  # We can parse:
  #
  # - method names
  # - class names
  # - instance method calls
  # - class method calls
  #
  # @example
  #   p = Yarr::InputParser.new
  #   p.parse 'ri a' # => {:command=>"ri", :method_name=>"a"}
  #   p.parse 'list B' # => {:command=>"list", :class_name=>"B"}
  #   pp p.parse 'ri A#b, phaul'
  #   # >> {:command=>"ri",
  #   # >>  :instance_method=>{:class_name=>"A", :method_name=>"b"},
  #   # >>  :stuff=>"phaul"}
  #   pp p.parse 'ast A.b'
  #   # >> {:command=>"ast",
  #   # >>  :class_method=>{:class_name=>"A", :method_name=>"b"}}
  #
  # @note We also accept % character anywhere to support like queries.
  class InputParser < Parslet::Parser
    rule(:input) do
      command >> spaces? >> expression >> (stuff_separator >> stuff).maybe
    end

    rule(:command) { (str('ri') | str('list') | str('ast')).as(:command) }

    rule(:stuff) { any.repeat.as(:stuff) }

    rule(:spaces?) { str(' ').repeat }

    rule(:stuff_separator) { match('[, ]') >> spaces? }

    rule(:expression) do
      instance_method.as(:instance_method) |
        class_method.as(:class_method) |
        # do not override the method :method.
        method_ |
        klass_origin |
        klass
    end

    rule(:instance_method) { klass >> str('#') >> method_ }

    rule(:class_method) { klass >> str('.') >> method_ }

    rule(:klass) do
      (match('[A-Z%]') >> match('[a-zA-Z:%]').repeat).as(:class_name)
    end

    rule(:method_) { (operator | suffixed | normal_name).as(:method_name) }

    rule(:klass_origin) { klass >> spaces? >> str(?() >> origin >> str(?)) }

    rule(:origin) { match('[a-z]').repeat(1).as(:origin_name) }

    # order of operators is important for the parser

    # Ruby operators
    # % is not in the list because then we would match the first % in %x% as an
    # operator, and then fail to parse the rest.
    Operators = %w[[]= === <=>
                   !~ != [] >> >= =~ == <= << ** -@ +@
                   ! ^ > < / - + * & ~]

    rule(:operator) { Operators.map(&method(:str)).inject(:|) }

    rule(:suffixed) { normal_name >> match('[?!=]') }

    rule(:normal_name) { match('[a-z%_]').repeat(1) }

    root(:input)

    # Same as Parslet::Parser#parse, except we return string hash values
    # @param string [String] the input to parse
    # @return [Hash] AST
    def parse(string, *args)
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
