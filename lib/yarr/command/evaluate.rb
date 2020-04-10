require 'yarr/evaluator_service'
require 'yarr/configuration'
require 'yarr/command/concern/ast_digger'
require 'yarr/message/truncator'

module Yarr
  module Command
    # evaluates the user's message using an online evaluation service like
    # carc.in
    class Evaluate < Base
      extend Concern::ASTDigger
      digger(:mode) { |mode| @config[:modes][mode || :default] }
      digger(:lang)
      digger(:code) { |code| preprocess(code.dup) }

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast.key? :evaluate
      end

      # @param web_service [#post] A web client that can post
      # @param configuration [Configuration] Configuration loaded
      # @see {Yarr::Base} for the rest of the arguments
      def initialize(ast:,
                     irc: NoIRC,
                     user: NoIRC::User.new,
                     web_service: EvaluatorService.new,
                     configuration: Yarr.config)
        super(ast: ast, irc: irc, user: user)

        @service = web_service
        @config = configuration.evaluator
      end

      # Runs the command
      def handle
        response =
          @service.request(EvaluatorService::Request.new(code, service_lang))
        respond_with(response)
      end

      private

      def filter(code)
        mode[:filter].each { |from, to| code.gsub!(from, to) }
        code
      end

      def preprocess(code)
        code = filter(code)
        format(template, code.lstrip)
      end

      def template
        format = mode[:format]
        case format
        when Hash then format[lang || :default]
        else format
        end
      end

      def respond_with(response)
        url = response.url
        case mode[:output]
        when :truncate
          response.output
        when :link
          "I have #{mode[:verb]} your code, the result is at #{url}"
        else
          raise ConfigFileError, 'output mode is neither :truncate nor :link'
        end
      end

      def service_lang
        @config[:languages][lang]
      end
    end
  end
end
