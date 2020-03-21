require 'parslet'
require 'yarr/ast'
require 'yarr/configuration'

module Yarr
  # == User input parser
  #
  # Recognised commands:
  # +ast{lang}>>+, +tok{lang}>>+, +asm{lang}>>+, +bare{lang}>>+, +{lang}>>+,
  # +asm+, +ri+, +list+, +fake+, +renick+, +fact+
  #
  # The +lang+ part is optional and it stands for a 2 digit ruby version
  # specifier, like 21 for 2.1. The rest of the input is context specific, and
  # parsed based on the command.
  #
  # == Evaluate commands
  #
  # The command is followed by an arbitrary ruby expression which is
  # subsequently sent to the evaluator. The AST always has a key :evaluate
  # which can be used to identify the command type. If +ast>>+, +tok>>+,
  # +asm>>+is used the sub part of AST will contain a +:mode+ set to +'ast'+,
  # +'tok'+ or +'asm'+. It can also contain a +:lang+ which is set to the
  # optional ruby version. The ast always contains a top level +:code+ that
  # contains the code to evaluate.
  #
  #   p = Yarr::InputParser.new
  #   p.parse('>> 1+1')
  #   # => #<Yarr::AST @hash={:evaluate=>"", :code=>" 1+1"}>
  #   p.parse('ast>> 1+1')
  #   # => #<Yarr::AST @hash={:evaluate=>{:mode=>"ast"}, :code=>" 1+1"}>
  #   p.parse('ast12>> 1+1')
  #   # => #<Yarr::AST @hash={:evaluate=>{:mode=>"ast", :lang=>"12"},
  #   #                                   :code=>" 1+1"}>
  #
  # == Non-evaluate commands
  #
  # The user input contains 3 sections, 2 required and 1 optional. The
  # sections are separated by white spaces.  Between the second and third
  # section an optional comma is allowed.  A usual user input might look like:
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
  # Examples
  #
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
  # @note We also accept % character in names to support like queries.
  #
  # == No argument commands
  #
  # Simple word commands
  #
  #  - renick
  class InputParser < Parslet::Parser
    # Error raised when parsing fails
    class ParseError < RuntimeError
      # @api private
      # This class should be only instantiated from within the {InputParser}
      def initialize(parslet_error)
        @parslet_error = parslet_error
      end

      # Reports the parse error occurred
      # @param message [String] original message of the bot
      # @return [String] bot response
      def report(message)
        cause = @parslet_error.parse_failure_cause
        position = cause.pos.charpos
        puts cause.ascii_tree if Yarr.config.development?
        "parser error at position #{position} around `#{message[position]}'"
      end
    end

    # Aliases that will be replaced in AST, so downstream doesn't have to handle
    # different options
    class AliasRewriter < Parslet::Transform
      rule('?') { 'fact' }
      rule('mk') { 'add' }
      rule('rm') { 'remove' }
      rule('ed') { 'edit' }
      rule('mv') { 'rename' }
    end
    private_constant :AliasRewriter

    rule(:input) do
      evaluate |
        ri_notation |
        url_evaluate |
        no_arg |
        fact_name_and_content |
        fact_rename |
        fact_delete |
        fact
    end

    rule(:no_arg) { (str('ops') | str('renick')).as(:command) }

    rule(:evaluate) { (override >> str('>>') >> code).as(:evaluate) }

    rule(:override) { (mode.maybe >> lang.maybe) }

    rule(:mode) do
      (str('asm') | str('ast') | str('tok') | str('bare')).as(:mode)
    end

    rule(:lang) { match('[0-9]').repeat(2).as(:lang) }

    rule(:code) { any.repeat.as(:code) }

    rule(:ri_notation) do
      ri_command >> spaces? >> expression >> stuff
    end

    rule(:ri_command) do
      (str('ri') | str('list') | str('fake')).as(:command)
    end

    rule(:stuff_separator) { match('[, ]') >> spaces? }

    rule(:stuff) { (stuff_separator >> any.repeat.as(:stuff)).maybe }

    rule(:spaces?) { str(' ').repeat }

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
      (match('[A-Z%]') >> match('[a-zA-Z0-9:%]').repeat).as(:class_name)
    end

    rule(:method_) { (operator | suffixed | normal_name).as(:method_name) }

    rule(:klass_origin) { klass >> spaces? >> str(?() >> origin >> str(?)) }

    rule(:origin) { match('[a-z]').repeat(1).as(:origin_name) }

    # order of operators is important for the parser

    # Ruby operators
    # % is not in the list because then we would match the first % in %x% as an
    # operator, and then fail to parse the rest.
    OPERATORS = %w[[]= === <=>
                   !~ != [] >> >= =~ == <= << ** -@ +@
                   ! ^ > < / - + * & ~ `].freeze

    rule(:operator) { OPERATORS.map(&method(:str)).inject(:|) }

    rule(:suffixed) { normal_name >> match('[?!=]') }

    rule(:normal_name) { match('[a-z%_]') >> match('[a-z0-9%_]').repeat }

    rule(:url_evaluate) do
      (str('url') >> spaces? >> url).as(:url_evaluate) >> stuff
    end

    rule(:url) { match('[^\s,]').repeat.as(:url) }

    rule(:fact) { fact_command >> spaces? >> fact_name >> stuff }

    rule(:fact_name_and_content) do
      fact_command >>
        spaces? >>
        (str('add') | str('mk') | str('edit') | str('ed')).as(:sub_command) >>
        spaces? >>
        fact_name >>
        spaces? >>
        fact_content
    end

    rule(:fact_rename) do
      fact_command >>
        spaces? >>
        (str('rename') | str('mv')).as(:sub_command) >>
        spaces? >>
        _fact_name.as(:old_name) >>
        spaces? >>
        _fact_name.as(:new_name)
    end

    rule(:fact_delete) do
      fact_command >>
        spaces? >>
        (str('remove') | str('rm')).as(:sub_command) >>
        spaces? >>
        fact_name
    end

    rule(:fact_content) { any.repeat.as(:content) }

    rule(:fact_command) { (str('fact') | str('?')).as(:command) }

    rule(:fact_name) { _fact_name.as(:name) }

    rule(:_fact_name) { match('[\w\d-]').repeat(1) }

    root(:input)

    # :reek:UncommunicativeVariableName

    # Same as Parslet::Parser#parse, except we return string hash values
    # @param string [String] the input to parse
    # @return [AST] abstract syntax tree of user input
    def parse(string, *args)
      AST.new(AliasRewriter.new.apply(super))
    rescue Parslet::ParseFailed => e
      raise ParseError, e
    end
  end
end
