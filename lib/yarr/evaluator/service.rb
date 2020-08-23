# frozen_string_literal: true

require 'typhoeus'
require 'yarr/evaluator/response'

module Yarr
  module Evaluator
    # A wrapper on a web request that uses carc.in
    class Service
      URL = 'https://carc.in/run_requests'
      # headers sent to web_service
      HEADERS = { 'Content-Type': 'application/json; charset=utf-8' }.freeze

      # @param web_service [Object] web service adaptor
      def initialize(web_service = Typhoeus)
        @web_service = web_service
      end

      # Sends a request to the web service and returns the response
      # @param request [Request] the code to evaluate
      # @return [Response] web service response object
      def request(request)
        response_body = @web_service.post(URL, body: request.to_wire, headers: HEADERS).response_body

        Response.new(response_body)
      end
    end
  end
end
