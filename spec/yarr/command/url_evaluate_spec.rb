require 'spec_helper'

require 'yarr/command/url_evaluate'

module Yarr
  module Command
    RSpec.describe URLEvaluate do
      let(:fetch_service) { double('fetch_service') }
      let(:evaluator_service) { instance_double(EvaluatorService) }
      let(:fetch_response) do
        double('fetch_response',
               response_code: 200,
               body: '1 + 1')
      end

      describe '#handle' do
        let(:ast) do
          Yarr::AST.new(url_evaluate: { url: 'fakegist.com' })
        end

        let(:command) do
          described_class.new(ast, fetch_service, evaluator_service)
        end

        it 'sends the right requests out' do
          expect(fetch_service).to receive(:get).with('fakegist.com')

          allow(fetch_service).to receive(:get).and_return(fetch_response)

          expect(evaluator_service).to receive(:request)
            .with(EvaluatorService::Request.new('1 + 1'))

          allow(evaluator_service).to receive(:request)
            .and_return(evaluator_response_double(stdout: '2'))

          command.handle
        end

        it 'returns the right result' do
          allow(fetch_service).to receive(:get).and_return(fetch_response)

          allow(evaluator_service).to receive(:request)
            .and_return(evaluator_response_double(stdout: '2'))

          expect(command.handle).to eq '# => 2 (http://fake.com/evaluated)'
        end

        context 'with invalid fetch url' do
          let(:bad_fetch) do
            double('fetch_response', response_code: 0, body: '')
          end

          it 'returns the error message' do
            allow(fetch_service).to receive(:get).and_return(bad_fetch)

            expect(command.handle).to eq 'Request returned response code 0'
          end
        end
      end
    end
  end
end
