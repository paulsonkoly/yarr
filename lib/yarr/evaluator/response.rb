# frozen_string_literal: true

require 'json'
require 'dry-schema'
require 'yarr/message/truncator'
require 'yarr/error'

module Yarr
  module Evaluator
    # response of the web request
    class Response
      SCHEMA = Dry::Schema.JSON do
        required(:run_request).hash do
          required(:run).hash do
            required(:html_url).filled(:string)
            required(:stderr).value(:string)
            required(:stdout).value(:string)
          end
        end
      end.freeze

      # @param data [String] raw data of the adapters response
      def initialize(data)
        @data = JSON.parse(data)
        result = SCHEMA.call(@data)
        raise UnexpectedServerResponseError, result.errors.to_h if result.failure?
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
  end
end
