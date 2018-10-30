require 'spec_helper'
require 'yarr/command/list'
require 'helpers/not_implemented_helper'

module Yarr
  module Command
    RSpec.describe 'list command' do
      let(:ast) { { class_name: '%', method_name: '%' } }

      describe List do
        subject { described_class.new(ast) }

        does_not_implement :query
        does_not_implement :target
      end

      describe ListCall do
        subject { described_class.new(ast) }

        does_not_implement :flavour
      end

      describe ListInstanceMethod do
        describe '#handle' do
          subject { described_class.new(ast).handle }

          it { is_expected.to eq  'Array#size, Array#abbrev' }
        end

        describe '#target' do
          subject { described_class.new(ast).send :target }

          it { is_expected.to eq 'instance method % on %' }
        end
      end

      describe ListClassMethod do
        describe '#handle' do
          subject do
            described_class.new(class_name: 'Arr%', method_name: 'n%').handle
          end

          it { is_expected.to eq  'Array.new' }
        end
      end

      describe ListClassName do
        describe '#handle' do
          subject { described_class.new(class_name: 'Array').handle }

          it { is_expected.to eq  'Array, Array (abbrev)' }
        end

        describe '#target' do
          subject { described_class.new(ast).send :target }

          it { is_expected.to eq 'class %' }
        end
      end

      describe ListMethodName do
        describe '#handle' do
          subject do
            described_class.new(method_name: 'si%').handle
          end

          it { is_expected.to eq  'Array#size' }

          describe '#target' do
            subject { described_class.new(ast).send :target }

            it { is_expected.to eq 'method %' }
          end
        end
      end
    end
  end
end
