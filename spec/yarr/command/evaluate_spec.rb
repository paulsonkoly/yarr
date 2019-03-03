require 'spec_helper'
require 'yarr/command/evaluate'
require 'json'

module Yarr
  module Command
    RSpec.describe Evaluate do
      let(:web_service) { instance_double(EvaluatorService) }

      def response_double(output)
        instance_double(
          EvaluatorService::Response,
          output: output,
          url: 'http://fake.com/evaluated')
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
                filter: [],
                format: "%s",
                output: :truncate
              },
              'ast' => {
                filter: {'\\' => '\\\\', '`' => '\\\`'},
                format: {
                  default: 'new ast of(%%q`%s`)',
                  '22' => 'ast of(%%q`%s`)'
                },
                output: :link,
                verb: 'cooked',
                escape: true
              }
            }
          }
        }
      end

      describe '#evaluate normal expression' do
        context 'of 1 + 1' do
          let(:ast) {  Yarr::AST.new(evaluate: { code: '1 + 1' }) }
          let(:command) { described_class.new(ast, web_service, configuration) }

          it 'sends the right request to web_service' do
            expect(web_service).to receive(:request)
              .with(EvaluatorService::Request.new('1 + 1'))

            allow(web_service)
              .to receive(:request).and_return(response_double('# => 2'))

            command.handle
          end

          it 'returns the right result' do
            allow(web_service)
              .to receive(:request).and_return(response_double('# => 2'))

            expect(command.handle)
              .to eq '# => 2 (http://fake.com/evaluated)'
          end
        end

        context 'of an expression whose result needs truncating' do
          let(:ast) {  Yarr::AST.new(evaluate: { code: 'Object.methods' }) }
          let(:command) { described_class.new(ast, web_service, configuration) }

          it 'truncates to the right size with the url' do
            allow(web_service).to receive(:request)
              .and_return(response_double("# => #{Object.methods}"))

            result = command.handle

            expect(result.length)
              .to be_within(20).of(Message::Truncator::MAX_LENGTH)
            expect(result.length).to be <= Message::Truncator::MAX_LENGTH
            expect(result)
              .to end_with "... check link for more (http://fake.com/evaluated)"
          end
        end
      end

      describe '#evaluate ast' do
        context 'of `1 + 1`' do
          let(:ast) do
            Yarr::AST.new(evaluate:
                          { mode: 'ast', lang: '22', code: '`1 + 1`' })
          end
          let(:command) { described_class.new(ast, web_service, configuration) }

          it 'sends the right request to web_service' do
            expect(web_service).to receive(:request)
              .with(EvaluatorService::Request.new('ast of(%q`\\`1 + 1\\``)', '2.2.2'))

            allow(web_service).to receive(:request).and_return(response_double('2'))
            command.handle
          end

          it 'returns the right result' do
            allow(web_service).to receive(:request).and_return(response_double('2'))
            expect(command.handle)
              .to eq 'I have cooked your code, the result is at http://fake.com/evaluated'
          end

          context 'with default lang' do
            let(:ast) do
              Yarr::AST.new(evaluate:
                            { mode: 'ast', code: '`1 + 1`' })
            end
            let(:command) do
              described_class.new(ast, web_service, configuration)
            end

            it 'sends the right request to web_service' do
              expect(web_service).to receive(:request)
                .with(EvaluatorService::Request.new('new ast of(%q`\\`1 + 1\\``)', '2.6.0'))

              allow(web_service)
                .to receive(:request).and_return(response_double('2'))
              command.handle
            end
          end
        end
      end
    end
  end
end
