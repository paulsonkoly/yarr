require 'spec_helper'

module Yarr
  module Command
    RSpec.describe ListInstanceMethod do
      let(:ast) { { class_name: '%', method_name: 'size' } }
      subject { described_class.new(ast) }

      describe '#handle' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::KlassAndMethod::Like).to receive(:query)
              .and_return(double('query-result',
            count: 2,
            entries: ['File#size', 'Array#size']))
          end

          it 'returns the list' do
            expect(subject.send(:handle)).to eql 'File#size, Array#size'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(Yarr::Query::KlassAndMethod::Like).to receive(:query)
              .and_return(double('query-result', count: 0))
          end

          it 'complains' do
            expect(subject.send(:handle)).to match('haven\'t found any')
          end
        end
      end
    end

    RSpec.describe ListClassMethod do
      let(:ast) { { class_name: '%', method_name: 'size' } }
      subject { described_class.new(ast) }

      describe '#handle' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::KlassAndMethod::Like).to receive(:query)
              .and_return(double('query-result',
            count: 2,
            entries: ['File.size', 'Array.size']))
          end

          it 'returns the list' do
            expect(subject.send(:handle)).to eql 'File.size, Array.size'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(Yarr::Query::KlassAndMethod::Like).to receive(:query)
              .and_return(double('query-result', count: 0))
          end

          it 'complains' do
            expect(subject.send(:handle)).to match('haven\'t found any')
          end
        end
      end
    end

    RSpec.describe ListClassName do
      let(:ast) { { class_name: '%', method_name: 'size' } }
      subject { described_class.new(ast) }

      describe '#handle' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::Klass::Like).to receive(:query)
              .and_return(double('query_result', count: 2, entries: ['Array', 'String']))
          end

          it 'returns the list' do
            expect(subject.send(:handle)).to eql 'Array, String'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(Yarr::Query::Klass::Like).to receive(:query)
              .and_return(double('query-result', count: 0))
          end

          it 'complains' do
            expect(subject.send(:handle)).to match('haven\'t found any')
          end
        end
      end
    end

    RSpec.describe ListMethodName do
      let(:ast) { { class_name: '%', method_name: 'size' } }
      subject { described_class.new(ast) }

      describe '#handle' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::Method::Like).to receive(:query)
              .and_return(double('query-result',
            count: 2,
            entries: ['File.size', 'Array#size']))
          end

          it 'returns the list' do
            expect(subject.send(:handle)).to eql 'File.size, Array#size'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(Yarr::Query::Method::Like).to receive(:query)
              .and_return(double('query-result', count: 0))
          end

          it 'complains' do
            expect(subject.send(:handle)).to match('haven\'t found any')
          end
        end
      end
    end
  end
end
