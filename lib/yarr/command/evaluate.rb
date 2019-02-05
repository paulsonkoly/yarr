require 'json'
require 'typhoeus'
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
      digger(:lang) { |lang| lang || :default }
      digger(:code) { |code| preprocess(code.dup) }

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
        { run_request: {
          language: 'ruby',
          version: @config[:languages][lang],
          code: code
        } }
      end

      def headers
        { 'Content-Type': 'application/json; charset=utf-8' }
      end

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
        when Hash then format[lang]
        else format
        end
      end

      def request_evaluation
        response = @service.post(url,
          body: payload.to_json,
          headers: headers
        ).response_body

        JSON.parse(response)
      end

      def respond_with(response)
        case mode[:output]
        when :truncate then truncate(response)
        when :link then link(response)
        else
          raise 'output mode is neither :truncate nor :link. config file error'
        end
      end

      def html_url(response)
        response['run_request']['run']['html_url']
      end

      def output(response)
        response['run_request']['run']['stdout']
      end

      def truncate(response)
        output = output(response)
        url = html_url(response)
        output.prepend('# => ')
        Message::Truncator.truncate(
          output,
          omission: '... check link for more',
          suffix: " (#{url})"
        )
      end

      def link(response)
        "I have #{mode[:verb]} your code, "\
          "the result is at #{html_url(response)}"
      end
    end
  end
end
