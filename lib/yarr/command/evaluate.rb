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

      # @private
      # The http response body
      class Response
        def initialize(data)
          @data = JSON.parse(data)
        end

        def html_url
          @data['run_request']['run']['html_url']
        end

        def output
          @data['run_request']['run']['stdout']
        end

        def truncate
          output.prepend('# => ')
          Message::Truncator.truncate(
            output,
            omission: '... check link for more',
            suffix: " (#{html_url})"
          )
        end
      end
      private_constant :Response

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
        response_body = @service.post(
          url,
          body: payload.to_json,
          headers: headers
        ).response_body

        Response.new(response_body)
      end

      def respond_with(response)
        case mode[:output]
        when :truncate then response.truncate
        when :link then link(response)
        else
          raise 'output mode is neither :truncate nor :link. config file error'
        end
      end

      def link(response)
        "I have #{mode[:verb]} your code, "\
          "the result is at #{response.html_url}"
      end
    end
  end
end
