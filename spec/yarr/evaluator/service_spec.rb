# frozen_string_literal: true

require 'spec_helper'

require 'yarr/evaluator/service'
require 'yarr/evaluator/request'

RSpec.describe Yarr::Evaluator::Service do
  let(:adaptor) { class_double(Typhoeus, 'adaptor') }
  let(:evaluator_service) { described_class.new(adaptor) }
  let(:request) { Yarr::Evaluator::Request.new('1 + 1') }
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

  describe '#initialize' do
    it 'defaults to Typhoeus' do
      expect(Typhoeus).to receive(:post).and_return(typhoeus_response)
      Yarr::Evaluator::Service.new.request(request)
    end

    it 'uses the given adaptor' do
      expect(adaptor).to receive(:post).and_return(typhoeus_response)

      evaluator_service.request(request)
    end
  end

  describe '#request' do
    it 'calls the evaluator service' do
      expect(adaptor).to receive(:post).with(
        described_class::URL,
        body: request.to_wire,
        headers: described_class::HEADERS
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
  end
end
