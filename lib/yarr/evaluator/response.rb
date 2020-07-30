# frozen_string_literal: true

require 'json'
require 'yarr/message/truncator'

module Yarr
  module Evaluator
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
  end
end
