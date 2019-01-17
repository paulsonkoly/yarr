require 'spec_helper'
require 'yarr/evaluator'
require 'json'

module Yarr
  RSpec.describe Evaluator do
    let(:web_service) { double('web-service') }

    def response_double(output)
      double('response', {
        response_body: {
          'run_request' =>
          { 'run' =>
            {
              'html_url' => 'http://fake.com/evaluated',
              'stdout' => output
            }
          }
        }.to_json
      })
    end

    def configuration_double(output = :truncate, format = "%s")
      double 'configuration', {
        evaluator: {
          url: 'http://fake.com',
          languages: { default: '2.6.0' },
          modes: {
            default: {
              format: format,
              output: output
            }
          }
        }
      }
    end

    def args(code)
      {
        body: %Q({"run_request":{"language":"ruby","version":"2.6.0","code":"#{code}"}}),
        headers: {:"Content-Type"=>"application/json; charset=utf-8"}
      }
    end

    describe '#evaluate normal exppression' do
      subject do
        described_class.new('', web_service, configuration_double)
      end

      context 'of 1 + 1' do
        it 'sends the right request to web_service' do
          expect(web_service).to receive(:post).with('http://fake.com', args('1 + 1'))
          allow(web_service).to receive(:post).and_return(response_double('2'))

          expect(subject.evaluate('1 + 1')).to eq '# => 2 (http://fake.com/evaluated)'
        end
      end
    end
  end
end
