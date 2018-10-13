require 'spec_helper'

module Yarr
  module Command
    RSpec.describe Ri do
      describe '#handle_instance_method' do
        context 'when there is a single result' do
          before do
            joint_result = double(method: double('method', url: 'definition.html'))
            allow(Yarr::Query::KlassAndMethod).to receive(:query)
              .and_return(double('query-result', first: joint_result, count: 1))
          end

          it 'returns the url' do
            expect(subject.send(:handle_instance_method)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(Yarr::Query::KlassAndMethod).to receive(:query)
              .and_return([1] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_instance_method)).to match('10')
          end
        end
      end

      describe '#handle_class_method' do
        context 'when there is a single result' do
          before do
            joint_result = double(method: double('method', url: 'definition.html'))
            allow(Yarr::Query::KlassAndMethod).to receive(:query)
              .and_return(double('query-result', first: joint_result, count: 1))
          end

          it 'returns the url' do
            expect(subject.send(:handle_class_method)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(Yarr::Query::KlassAndMethod).to receive(:query)
              .and_return([1] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_class_method)).to match('10')
          end
        end
      end

      describe '#handle_class_name' do
        context 'when there is a single result' do
          before do
            klass = double('klass', url: 'definition.html')
            allow(Yarr::Query::Klass).to receive(:query)
              .and_return(double('query-result', count: 1, first: klass))
          end

          it 'returns the url' do
            expect(subject.send(:handle_class_name)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(Yarr::Query::Klass).to receive(:query).and_return([1] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_class_name)).to match('10')
          end
        end
      end

      describe '#handle_method_name' do
        context 'when there is a single result' do
          before do
            method = double('method', url: 'definition.html')
            allow(Yarr::Query::Method).to receive(:query)
              .and_return(double('query-result', count: 1, first: method))
          end

          it 'returns the url' do
            expect(subject.send(:handle_method_name)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is more than 1' do
          before do
            allow(Yarr::Query::Method).to receive(:query).and_return([1] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_method_name)).to match('10')
          end
        end

        context 'when there is no result' do
          it 'returns the count' do
            expect(subject.send(:handle_method_name)).to match('no entry')
          end
        end
      end
    end
  end
end
