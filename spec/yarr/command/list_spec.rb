require 'spec_helper'
require 'yarr/command/list'

module Yarr
  module Command
    RSpec.describe 'list command' do
      let(:ast) { { class_name: '%', method_name: '%' } }

      describe List do
        subject { described_class.new(ast) }

        describe '#target' do
          it 'raises NotImplementedError' do
            expect { subject.send :target }.to raise_error NotImplementedError
          end
        end
      end

      describe ListCall do
        subject { described_class.new(ast) }

        describe '#flavour' do
          it 'raises NotImplementedError' do
            expect { subject.send :flavour }.to raise_error NotImplementedError
          end
        end
      end

      describe ListInstanceMethod do
        describe '#handle' do
          subject { described_class.new(ast).handle }

          it { is_expected.to eq  'Array#size, Array#abbrev' }
        end
      end

      describe ListClassMethod do
        describe '#handle' do
          subject do
            described_class.new(class_name: 'Arr%', method_name: 'n%').handle
          end

          it { is_expected.to eq  'Array.new' }

          context 'when nothing is found' do
            subject do
              described_class.new(class_name: 'NonExistent').handle
            end

            it { is_expected.to match(/\AI haven't found any/) }
          end
        end
      end

      describe ListClassName do
        describe '#handle' do
          subject { described_class.new(class_name: 'Array').handle }

          it { is_expected.to eq  'Array, Array (abbrev)' }

          context 'when nothing is found' do
            subject do
              described_class.new(class_name: 'NonExistent').handle
            end

            it { is_expected.to match(/\AI haven't found any/) }
          end
        end
      end

      describe ListMethodName do
        describe '#handle' do
          subject do
            described_class.new(method_name: 'si%').handle
          end

          it { is_expected.to eq  'Array#size' }

          context 'when nothing is found' do
            subject do
              described_class.new(method_name: 'non_existent').handle
            end

            it { is_expected.to match(/\AI haven't found any/) }
          end
        end
      end
    end
  end
end
