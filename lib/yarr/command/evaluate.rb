require 'yarr/command/concern/ast_digger'
require 'yarr/message/truncator'
require 'yarr/dependencies'

module Yarr
  module Command
    # evaluates the user's message using an online evaluation service like
    # carc.in
    class Evaluate < Base
      extend Concern::ASTDigger
      digger(:mode) { |mode| config[:modes][mode || :default] }
      digger(:lang)
      digger(:code) { |code| preprocess(code.dup) }

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast.key? :evaluate
      end

      include Import[
        'services.evaluator_service',
        'services.evaluator_service.request',
        'irc',
        'configuration'
      ]

      # Runs the command
      def handle
        request_ = request.new(code, service_lang)
        response = evaluator_service.request(request_)
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
          raise 'output mode is neither :truncate nor :link. config file error'
        end
      end

      def config
        configuration.evaluator
      end

      def service_lang
        config[:languages][lang]
      end
    end
  end
end
