require 'yarr/message/command'

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

    RSpec.describe Command do
      describe '#stringify_hash_values' do
        subject do
          Command.new.send(:stringify_hash_values, { a: 1, b: { c: 2 } })
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
    end
  end
end
