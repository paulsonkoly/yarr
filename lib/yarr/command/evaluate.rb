require 'json'
require 'typhoeus'
require 'yarr/configuration'
require 'yarr/command/concern/ast_digger'
require 'yarr/message/truncator'

module Yarr
  module Command
    # evaluates the user's message using an online evaluation service like carc.in
    class Evaluate < Base
      extend Concern::ASTDigger
      digger(:mode) { |mode| @config[:modes][mode || :default] }
      digger(:lang) { |lang| @config[:languages][lang || :default] }
      digger(:code) { |code| massage_code(code) }

      def self.match?(ast)
        ast.key? :evaluate
      end

      # @param web_service [#post] A web client that can post
      # @param config [Configuration] Configuration loaded
      def initialize(ast, web_service = Typhoeus, config = Yarr.config)
        super(ast)

        @service = web_service
        @config = config.evaluator
      end

      def handle
        response = request_evaluation
        respond_with(response)
      end

      private

      def url
        @config[:url]
      end

      def payload
        {run_request: {language: 'ruby', version: lang, code: code}}
      end

      def headers
        {'Content-Type': 'application/json; charset=utf-8'}
      end

      def massage_code(code)
        code = code.dup
        if mode[:escape]
          code.gsub!("\\", "\\\\")
          code.gsub!('`', '\\\`')
        end

        sprintf format, code.lstrip
      end

      def format
        format = mode[:format]
        case format
        when Hash then format[lang]
        else format
        end
      end

      def request_evaluation
        response = @service.post(url, {
          body: payload.to_json,
          headers: headers
        }).response_body

        JSON.parse(response)
      end

      def respond_with(response)
        url = response['run_request']['run']['html_url']
        output = response['run_request']['run']['stdout']

        case mode[:output]
        when :truncate
          output.prepend('# => ')
          max_length = Message::Truncator::MAX_LENGTH - url.length - 3
          output = Message::Truncator.truncate(
            output,
            omission: "... check link for more",
            max_length: max_length
          )
          output << " (#{url})"
        when :link
          "I have #{mode[:verb]} your code, the result is at #{url}"
        else
          raise RuntimeError,
            'output mode is neither :truncate nor :link. config file error'
        end
      end
    end
  end
end
