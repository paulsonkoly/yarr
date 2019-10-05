require 'spec_helper'

require 'yarr/evaluator_service'

module Yarr
  RSpec.describe EvaluatorService do
    let(:adaptor) { class_double(Typhoeus, 'adaptor') }

    let(:evaluator_service) { described_class.new(adaptor) }

    describe '#request' do
      let(:request) { EvaluatorService::Request.new('1 + 1') }
      let(:typhoeus_response) do
        instance_double(
          Typhoeus::Response,
          response_body: {
            'run_request' =>
            { 'run' =>
              {
                'html_url' => 'http://fake.com/evaluated',
                'stdout' => '1',
                'stderr' => ''
              } }
          }.to_json
        )
      end

      it 'calls the evaluator service' do
        expect(adaptor).to receive(:post).with(
          anything,
          body: request.to_wire,
          headers: anything
        ).and_return(typhoeus_response)

        evaluator_service.request(request)
      end

      it 'response has the right data' do
        allow(adaptor).to receive(:post).with(
          anything,
          body: request.to_wire,
          headers: anything
        ).and_return(typhoeus_response)

        service_response = evaluator_service.request(request)
        expect(service_response).to have_attributes(
          output: '# => 1 (http://fake.com/evaluated)'
        )
      end

      context 'with stderr content' do
        let(:typhoeus_response) do
          instance_double(
            Typhoeus::Response,
            response_body: {
              'run_request' =>
              { 'run' =>
                {
                  'html_url' => 'http://fake.com/evaluated',
                  'stdout' => '',
                  'stderr' => 'error occured'
                } }
            }.to_json
          )
        end

        it 'response output contains the error' do
          allow(adaptor).to receive(:post).with(
            anything,
            body: request.to_wire,
            headers: anything
          ).and_return(typhoeus_response)

          service_response = evaluator_service.request(request)
          expect(service_response).to have_attributes(
            output: 'stderr: error occured (http://fake.com/evaluated)'
          )
        end
      end

      context 'with both stdout and stderr content' do
        let(:typhoeus_response) do
          instance_double(
            Typhoeus::Response,
            response_body: {
              'run_request' =>
              { 'run' =>
                {
                  'html_url' => 'http://fake.com/evaluated',
                  'stdout' => "1\n",
                  'stderr' => "error occured\n"
                } }
            }.to_json
          )
        end

        it 'response output contains both' do
          allow(adaptor).to receive(:post).with(
            anything,
            body: request.to_wire,
            headers: anything
          ).and_return(typhoeus_response)

          service_response = evaluator_service.request(request)
          expect(service_response).to have_attributes(
            output: '# => 1 stderr: error occured (http://fake.com/evaluated)'
          )
        end
      end

      context 'with an expression whose result needs truncating' do
        let(:typhoeus_response) do
          instance_double(
            Typhoeus::Response,
            response_body: {
              'run_request' =>
              { 'run' =>
                {
                  'html_url' => 'http://fake.com/evaluated',
                  'stdout' => Object.methods.to_s,
                  'stderr' => ''
                } }
            }.to_json
          )
        end

        it 'truncates to the right size with the url' do
          allow(adaptor).to receive(:post).with(
            anything,
            body: request.to_wire,
            headers: anything
          ).and_return(typhoeus_response)

          service_response = evaluator_service.request(request)
          message_length = service_response.output.length

          expect(message_length)
            .to be_within(20).of(Message::Truncator::MAX_LENGTH)
          expect(message_length)
            .to be <= Message::Truncator::MAX_LENGTH
          expect(service_response.output)
            .to end_with '... check link for more (http://fake.com/evaluated)'
        end
      end
    end
  end
end
