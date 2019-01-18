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

    let(:configuration) do
      double 'configuration', {
        evaluator: {
          url: 'http://fake.com',
          languages: {
            default: '2.6.0',
            '22' => '2.2.2'
          },
          modes: {
            default: {
              format: "%s",
              output: :truncate
            },
            'ast' => {
              format: "ast_of(%%q`%s`)",
              output: :link,
              verb: 'cooked',
              escape: true
            }
          }
        }
      }
    end

    def args(code, language = '2.6.0')
      {
        body: %Q({"run_request":{"language":"ruby","version":"#{language}","code":"#{code}"}}),
        headers: {:"Content-Type"=>"application/json; charset=utf-8"}
      }
    end

    describe '#evaluate normal expression' do
      subject do
        described_class.new('', web_service, configuration)
      end

      context 'of 1 + 1' do
        it 'sends the right request to web_service' do
          expect(web_service).to receive(:post)
            .with('http://fake.com', args('1 + 1'))
          allow(web_service).to receive(:post).and_return(response_double('2'))
          subject.evaluate('1 + 1')
        end

        it 'returns the right result' do
          allow(web_service).to receive(:post).and_return(response_double('2'))
          expect(subject.evaluate('1 + 1')).to eq '# => 2 (http://fake.com/evaluated)'
        end
      end
    end

    describe '#evaluate ast' do
      subject do
        described_class.new('ast22', web_service, configuration)
      end

      context 'of `1 + 1`' do
        it 'sends the right request to web_service' do
          expect(web_service).to receive(:post)
            .with('http://fake.com', args('ast_of(%q`\\\\`1 + 1\\\\``)', '2.2.2'))
          allow(web_service).to receive(:post).and_return(response_double('2'))
          subject.evaluate('`1 + 1`')
        end

        it 'returns the right result' do
          allow(web_service).to receive(:post).and_return(response_double('2'))
          expect(subject.evaluate('1 + 1'))
            .to eq 'I have cooked your code, the result is at http://fake.com/evaluated'
        end
      end
    end
  end
end
