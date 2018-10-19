require 'spec_helper'
require 'yarr/command/ri'

module Yarr
  module Command
    RSpec.describe RiInstanceMethod do
      let(:ast) { { class_name: '%', method_name: 'size' } }
      subject { described_class.new(ast) }

      describe '#handle' do
        context 'when there is a single result' do
          before do
            joint_result = double(method: double('method', url: 'definition.html'))
            allow(Yarr::Query::KlassAndMethod::Strict).to receive(:query)
              .and_return(double('query-result', first: joint_result, count: 1))
          end

          it 'returns the url' do
            expect(subject.send(:handle)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(Yarr::Query::KlassAndMethod::Strict).to receive(:query)
              .and_return([1] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle)).to match('10')
          end
        end
      end
    end

    RSpec.describe RiClassMethod do
      let(:ast) { { class_name: '%', method_name: 'size' } }
      subject { described_class.new(ast) }

      describe '#handle' do
        context 'when there is a single result' do
          before do
            joint_result = double(method: double('method', url: 'definition.html'))
            allow(Yarr::Query::KlassAndMethod::Strict).to receive(:query)
              .and_return(double('query-result', first: joint_result, count: 1))
          end

          it 'returns the url' do
            expect(subject.send(:handle)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(Yarr::Query::KlassAndMethod::Strict).to receive(:query)
              .and_return([1] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle)).to match('10')
          end
        end
      end
    end


    RSpec.describe RiClassName do
      let(:ast) { { class_name: '%'} }
      subject { described_class.new(ast) }

      describe '#handle' do
        let(:klass) { double('klass', url: 'definition.html', origin: 'test') }

        context 'when there is a single result' do
          before do
            allow(Yarr::Query::Klass::Strict).to receive(:query)
              .and_return([klass])
          end

          it 'returns the url' do
            expect(subject.send(:handle)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          context 'when one of the results comes from core' do
            let(:core_klass) do
              double('klass', url: 'url.html', origin: 'core')
            end

            before do
              allow(Yarr::Query::Klass::Strict).to receive(:query)
                .and_return(([klass] * 10) << core_klass)
            end

            it 'returns the url' do
              expect(subject.send(:handle)).to end_with 'url.html'
            end
          end

          context 'when none of the results come from core' do
            before do
              allow(Yarr::Query::Klass::Strict).to receive(:query)
                .and_return([klass] * 10)
            end

            it 'returns the count' do
              expect(subject.send(:handle)).to match('10')
            end
          end
        end
      end
    end

    RSpec.describe RiMethodName do
      let(:ast) { { class_name: '%'} }
      subject { described_class.new(ast) }

      describe '#handle' do
        context 'when there is a single result' do
          before do
            method = double('method', url: 'definition.html')
            allow(Yarr::Query::Method::Strict).to receive(:query)
              .and_return(double('query-result', count: 1, first: method))
          end

          it 'returns the url' do
            expect(subject.send(:handle)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is more than 1' do
          before do
            allow(Yarr::Query::Method::Strict).to receive(:query).and_return([1] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle)).to match('10')
          end
        end

        context 'when there is no result' do
          before do
            allow(Yarr::Query::Method::Strict).to receive(:query).and_return([])
          end

          it 'returns the count' do
            expect(subject.send(:handle)).to match('no entry')
          end
        end
      end
    end
  end
end
