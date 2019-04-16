require 'json'
require 'typhoeus'
require 'dry-equalizer'

require 'yarr/message/truncator'

module Yarr
  # A wrapper on a web request that uses carc.in
  class EvaluatorService
    URL = 'https://carc.in/run_requests'.freeze
    CURRENT_RUBY='2.6.0'.freeze

    # @param web_service [Object] web service adaptor
    def initialize(web_service = Typhoeus)
      @web_service = web_service
    end

    # Sends a request to the web service and returns the response
    # @param request [Request] the code to evaluate
    # @return [Response] web service response object
    def request(request)
      response_body = @web_service.post(
        URL,
        body: request.to_wire,
        headers: headers
      ).response_body

      Response.new(response_body)
    end

    # Request that's sent to web service.
    class Request
      attr_reader :code, :lang
      include Dry::Equalizer(:code, :lang)

      def initialize(code, lang = CURRENT_RUBY)
        @code = code
        @lang = lang
      end

      # Serializes the request ready to be sent
      def to_wire
        { run_request: {
          language: 'ruby',
          version: @lang,
          code: @code
        } }.to_json
      end
    end

    # response of the web request
    class Response
      # @param data [String] raw data of the adapters response
      def initialize(data)
        @data = JSON.parse(data)
      end

      # url that points to the evaluation
      def url
        @data['run_request']['run']['html_url']
      end

      # unified stdout / stderr with appropriate rocket / stderr prefix
      def output
        out = stdout
        out.prepend('# => ') unless out.empty?
        err = stderr
        err.prepend('stderr: ') unless err.empty?

        Message::Truncator.truncate(
          out << ' ' << err,
          omission: '... check link for more',
          suffix: " (#{url})"
        )
      end

      private

      def results
        @data['run_request']['run']
      end

      def stderr
        results['stderr']
      end

      def stdout
        results['stdout']
      end
    end

    private

    def headers
      { 'Content-Type': 'application/json; charset=utf-8' }
    end
  end
end
