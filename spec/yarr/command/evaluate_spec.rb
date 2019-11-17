require 'spec_helper'
require 'yarr/command/evaluate'
require 'json'

module Yarr
  module Command
    RSpec.describe Evaluate do
      let(:evaluator_service) { instance_double(EvaluatorService) }

      let(:configuration) do
        double 'configuration',
               evaluator: {
                 url: 'http://fake.com',
                 languages: {
                   '22' => '2.2.2'
                 },
                 modes: {
                   default: {
                     filter: [],
                     format: '%s',
                     output: :truncate
                   },
                   'ast' => {
                     filter: { '\\' => '\\\\', '`' => '\\\`' },
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
      end

      let(:command) do
        described_class.new(ast: ast,
                            evaluator_service: evaluator_service,
                            configuration: configuration)
      end

      describe '#handle' do
        context 'with 1 + 1' do
          let(:ast) { Yarr::AST.new(evaluate: { code: '1 + 1' }) }

          it 'sends the right request to evaluator_service' do
            expect(evaluator_service).to receive(:call)
              .with(request: EvaluatorService::Request.new('1 + 1'))

            allow(evaluator_service)
              .to receive(:call)
              .and_return(evaluator_response_double(stdout: '2'))

            command.handle
          end

          it 'returns the right result' do
            allow(evaluator_service)
              .to receive(:call)
              .and_return(evaluator_response_double(stdout: '2'))

            expect(command.handle)
              .to eq '# => 2 (http://fake.com/evaluated)'
          end
        end

        context 'with mode ast and lang 22' do
          let(:ast) do
            Yarr::AST.new(evaluate:
                          { mode: 'ast', lang: '22', code: '`1 + 1`' })
          end

          it 'sends the right request to evaluator_service' do
            expect(evaluator_service).to receive(:call)
              .with(request: EvaluatorService::Request.new('ast of(%q`\\`1 + 1\\``)', '2.2.2'))

            allow(evaluator_service)
              .to receive(:call)
              .and_return(evaluator_response_double(stdout: '2'))
            command.handle
          end

          it 'returns the right result' do
            allow(evaluator_service)
              .to receive(:call)
              .and_return(evaluator_response_double(stdout: '2'))
            expect(command.handle)
              .to eq 'I have cooked your code, the result is at http://fake.com/evaluated'
          end
        end

        context 'with default lang' do
          let(:ast) do
            Yarr::AST.new(evaluate:
                          { mode: 'ast', code: '`1 + 1`' })
          end

          it 'sends the right request to evaluator_service' do
            expect(evaluator_service).to receive(:call)
              .with(request: EvaluatorService::Request.new('new ast of(%q`\\`1 + 1\\``)'))

            allow(evaluator_service)
              .to receive(:call)
              .and_return(evaluator_response_double(stdout: '2'))
            command.handle
          end
        end
      end
    end
  end
end
