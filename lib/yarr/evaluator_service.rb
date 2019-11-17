require 'json'
require 'dry-equalizer'
require 'dry-transaction'
require 'yarr/dependencies'

require 'yarr/message/truncator'

module Yarr
  # A wrapper on a web request that uses carc.in
  class EvaluatorService
    URL = 'https://carc.in/run_requests'.freeze

    include Dry::Transaction
    include Import['services.fetch_service']

    step :post_request
    step :get_body
    step :create_response

    # Request that's sent to web service.
    class Request
      attr_reader :code, :lang
      include Dry::Equalizer(:code, :lang)

      # Creates a new Request to be sent for evaluation
      # @param code [String|nil] code to be evaluated
      # @param lang [String|nil] Ruby version
      def initialize(code, lang = nil)
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
        out = stdout.chomp # truncator outputs max one line
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

    def post_request(request:)
      Success(fetch_service.post(URL, body: request.to_wire, headers: headers))
    end

    def get_body(response)
      # TODO: what if not 200?
      Success(response.response_body)
    end

    def create_response(response_body)
      Success(Response.new(response_body))
    end

    def headers
      { 'Content-Type': 'application/json; charset=utf-8' }
    end
  end
end
