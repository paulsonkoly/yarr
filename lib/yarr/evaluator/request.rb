# frozen_string_literal: true

require 'json'
require 'dry-equalizer'

require 'yarr/message/truncator'

module Yarr
  module Evaluator
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
  end
end
