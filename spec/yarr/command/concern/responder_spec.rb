require 'yarr/command/concern/responder'

module Yarr
  module Command
    module Concern
      RSpec.describe Responder do
        describe '.define_multi_item_responder' do
          let(:responder) do
            klass = described_class
            Class.new do
              include klass

              def target
                'test'
              end

              define_multi_item_responder { |result| result.map(&:upcase) }
            end.new
          end

          context 'when result is empty' do
            it 'raises AnswerAmbiguityError with no entry in the message' do
              expect { responder.send(:response, []) }
                .to raise_error(AnswerAmbiguityError,
                                'Found no entry that matches test')
            end
          end

          context 'with multiple results' do
            it 'responds with the lambda applied on results' do
              expect(responder.send(:response, %w[a b c])).to eq %w[A B C]
            end
          end
        end

        describe '.define_single_item_responder' do
          let(:responder) do
            klass = described_class
            Class.new do
              include klass

              def target
                'test'
              end

              define_single_item_responder { |result| result.first.upcase }
            end.new
          end

          context 'when result is empty' do
            it 'raises AnswerAmbiguityError with no entry in the message' do
              expect { responder.send(:response, []) }
                .to raise_error(AnswerAmbiguityError,
                                'Found no entry that matches test')
            end
          end

          context 'with exactly one result' do
            it 'responds with the lambda applied on the result' do
              expect(responder.send(:response, ['a'])).to eq 'A'
            end
          end

          context 'with multiple results' do
            it 'raises AnswerAmbiguityError with the matches in the message' do
              expect { responder.send(:response, %w[a b c]) }
                .to raise_error(AnswerAmbiguityError,
                                'I found 3 entries matching test.')
            end
          end

          context 'with non-empty advice' do
            let(:responder) do
              klass = described_class
              Class.new do
                include klass

                def target
                  'test'
                end

                def advice
                  'Go do something else.'
                end

                define_single_item_responder { |result| result.first.upcase }
              end.new
            end

            context 'with multiple results' do
              it 'raises AnswerAmbiguityError with the advice in the message' do
                expect { responder.send(:response, %w[a b c]) }
                  .to raise_error(
                    AnswerAmbiguityError,
                    'I found 3 entries matching test. Go do something else.'
                  )
              end
            end
          end
        end
      end
    end
  end
end
