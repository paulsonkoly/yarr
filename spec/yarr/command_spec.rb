require 'spec_helper'
require 'yarr/command'

module Yarr
  module Message
    RSpec.describe WhatIsCommand do
      let(:ast) { { some_ast: {deep: 1} } }

      describe '#handle' do
        subject { WhatIsCommand.new.handle(ast) }

        it { is_expected.to start_with('It\'s a(n) ') }
        it { is_expected.to match(/some ast/) }
      end
    end

    RSpec.describe QueryCommand do
      describe '#stringify_hash_values' do
        subject do
          described_class.new.send(:stringify_hash_values, { a: 1, b: { c: 2 } })
        end

        it { is_expected.to eq({ a: '1', b: { c: '2' } }) }
      end

      describe '#handle' do
        context 'with instance method' do

          let(:ast) do
            { instance_method: { class_name: 'Array', method_name: 'size' } }
          end

          before { allow(subject).to receive(:handle_instance_method) }

          it 'dispatches to #handle_instance_method' do
            subject.handle(ast)
            expect(subject).to have_received(:handle_instance_method)
          end

          it 'sets @klass' do
            expect { subject.handle(ast) }.to(
              change { subject.instance_variable_get(:@klass) }.to('Array'))
          end

          it 'sets @method' do
            expect { subject.handle(ast) }.to(
              change { subject.instance_variable_get(:@method) }.to('size'))
          end
        end
      end

      context 'with class method' do
        let(:ast) do
          { class_method: { class_name: 'File', method_name: 'size' } }
        end

        before { allow(subject).to receive(:handle_class_method) }

        it 'dispatches to #handle_class_method' do
          subject.handle(ast)
          expect(subject).to have_received(:handle_class_method)
        end

        it 'sets @klass' do
          expect { subject.handle(ast) }.to(
            change { subject.instance_variable_get(:@klass) }.to('File'))
        end

        it 'sets @method' do
          expect { subject.handle(ast) }.to(
            change { subject.instance_variable_get(:@method) }.to('size'))
        end
      end

      context 'with method name' do
        let(:ast) { { method_name: 'puts' } }

        before { allow(subject).to receive(:handle_method_name) }

        it 'dispatches to #handle_method_name' do
          subject.handle(ast)
          expect(subject).to have_received(:handle_method_name)
        end

        it 'sets @method' do
          expect { subject.handle(ast) }.to(
            change { subject.instance_variable_get(:@method) }.to('puts'))
        end
      end

      context 'with class name' do
        let(:ast) { { class_name: 'IO' } }

        before { allow(subject).to receive(:handle_class_name) }

        it 'dispatches to #handle_class_name' do
          subject.handle(ast)
          expect(subject).to have_received(:handle_class_name)
        end

        it 'sets @klass' do
          expect { subject.handle(ast) }.to(
            change { subject.instance_variable_get(:@klass) }.to('IO'))
        end
      end
    end

    RSpec.describe RiCommand do
      let(:query_adaptor) { double('query_adaptor') }
      subject { RiCommand.new(query_adaptor) }

      describe '#handle_instance_method' do
        context 'when there is a single result' do
          before do
            allow(query_adaptor).to receive(:joined_query).and_return(
              [url: 'definition.html'])
          end

          it 'returns the url' do
            expect(subject.send(:handle_instance_method)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(query_adaptor).to receive(:joined_query).and_return(
              [url: 'definition.html'] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_instance_method)).to match('10')
          end
        end
      end

      describe '#handle_class_method' do
        context 'when there is a single result' do
          before do
            allow(query_adaptor).to receive(:joined_query).and_return(
              [url: 'definition.html'])
          end

          it 'returns the url' do
            expect(subject.send(:handle_class_method)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(query_adaptor).to receive(:joined_query).and_return(
              [url: 'definition.html'] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_class_method)).to match('10')
          end
        end
      end

      describe '#handle_class_name' do
        context 'when there is a single result' do
          before do
            allow(query_adaptor).to receive(:klass_query).and_return(
              [url: 'definition.html'])
          end

          it 'returns the url' do
            expect(subject.send(:handle_class_name)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is not 1' do
          before do
            allow(query_adaptor).to receive(:klass_query).and_return(
              [url: 'definition.html'] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_class_name)).to match('10')
          end
        end
      end

      describe '#handle_method_name' do
        context 'when there is a single result' do
          before do
            allow(query_adaptor).to receive(:method_query).and_return(
              [url: 'definition.html'])
          end

          it 'returns the url' do
            expect(subject.send(:handle_method_name)).to end_with 'definition.html'
          end
        end

        context 'when the number of results is more than 1' do
          before do
            allow(query_adaptor).to receive(:method_query).and_return(
              [url: 'definition.html'] * 10)
          end

          it 'returns the count' do
            expect(subject.send(:handle_method_name)).to match('10')
          end
        end

        context 'when there is no result' do
          before do
            allow(query_adaptor).to receive(:method_query).and_return([])
          end

          it 'returns the count' do
            expect(subject.send(:handle_method_name)).to match('no entry')
          end
        end
      end
    end

    RSpec.describe ListCommand do
      let(:query_adaptor) { double('query_adaptor') }
      let(:multi_result) { [{ class_name: 'File', method_name: 'size' },
                            { class_name: 'Array', method_name: 'size' }] }
      subject { ListCommand.new(query_adaptor) }

      describe '#handle_instance_method' do
        context 'when there is at least one result' do
          before do
            allow(query_adaptor).to receive(:joined_like_query)
              .and_return(multi_result)
          end

          it 'returns the list' do
            expect(subject.send(:handle_instance_method)).to eql 'File#size, Array#size'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(query_adaptor).to receive(:joined_like_query).and_return([])
          end

          it 'complains' do
            expect(subject.send(:handle_instance_method)).to match('haven\'t found any')
          end
        end
      end

      describe '#handle_class_method' do
        context 'when there is at least one result' do
          before do
            allow(query_adaptor).to receive(:joined_like_query)
              .and_return(multi_result)
          end

          it 'returns the list' do
            expect(subject.send(:handle_class_method)).to eql 'File.size, Array.size'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(query_adaptor).to receive(:joined_like_query).and_return([])
          end

          it 'complains' do
            expect(subject.send(:handle_class_method)).to match('haven\'t found any')
          end
        end
      end

      describe '#handle_class_name' do
        context 'when there is at least one result' do
          before do
            allow(query_adaptor).to receive(:klass_like_query).and_return(
              [{ name: 'Array' }, { name: 'String' }])
          end

          it 'returns the list' do
            expect(subject.send(:handle_class_name)).to eql 'Array, String'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(query_adaptor).to receive(:klass_like_query).and_return([])
          end

          it 'complains' do
            expect(subject.send(:handle_class_name)).to match('haven\'t found any')
          end
        end
      end

      describe '#handle_method_name' do
        context 'when there is at least one result' do
          before do
            allow(query_adaptor).to receive(:method_like_query)
              .and_return([
                { class_name: 'File', method_name: 'size', method_flavour: 'class' },
                { class_name: 'Array', method_name: 'size', method_flavour: 'instance'},
                { class_name: 'bad', method_name: 'worse', method_flavour: 'nonexistent'}])
          end

          it 'returns the list' do
            expect(subject.send(:handle_method_name)).to eql 'File.size, Array#size, bad???worse'
          end
        end

        context 'when the number of results is 0' do
          before do
            allow(query_adaptor).to receive(:method_like_query).and_return([])
          end

          it 'complains' do
            expect(subject.send(:handle_method_name)).to match('haven\'t found any')
          end
        end
      end
    end
  end
end
