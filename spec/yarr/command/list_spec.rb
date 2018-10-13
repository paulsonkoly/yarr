require 'spec_helper'

module Yarr
  module Command
    RSpec.describe List do
      describe '#handle_instance_method' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::KlassAndMethod).to receive(:query)
              .and_return(double('query-result',
            count: 2,
            entries: ['File#size', 'Array#size']))
          end

          it 'returns the list' do
            expect(subject.send(:handle_instance_method)).to eql 'File#size, Array#size'
          end
        end

        context 'when the number of results is 0' do
          it 'complains' do
            expect(subject.send(:handle_instance_method)).to match('haven\'t found any')
          end
        end
      end

      describe '#handle_class_method' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::KlassAndMethod).to receive(:query)
              .and_return(double('query-result',
            count: 2,
            entries: ['File.size', 'Array.size']))
          end

          it 'returns the list' do
            expect(subject.send(:handle_class_method)).to eql 'File.size, Array.size'
          end
        end

        context 'when the number of results is 0' do
          it 'complains' do
            expect(subject.send(:handle_class_method)).to match('haven\'t found any')
          end
        end
      end

      describe '#handle_class_name' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::Klass).to receive(:query)
              .and_return(double('query_result', count: 2, entries: ['Array', 'String']))
          end

          it 'returns the list' do
            expect(subject.send(:handle_class_name)).to eql 'Array, String'
          end
        end

        context 'when the number of results is 0' do
          it 'complains' do
            expect(subject.send(:handle_class_name)).to match('haven\'t found any')
          end
        end
      end

      describe '#handle_method_name' do
        context 'when there is at least one result' do
          before do
            allow(Yarr::Query::Method).to receive(:query)
              .and_return(double('query-result',
            count: 2,
            entries: ['File.size', 'Array#size']))
          end

          it 'returns the list' do
            expect(subject.send(:handle_method_name)).to eql 'File.size, Array#size'
          end
        end

        context 'when the number of results is 0' do
          it 'complains' do
            expect(subject.send(:handle_method_name)).to match('haven\'t found any')
          end
        end
      end
    end
  end
end
