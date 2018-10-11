require_relative '../spec_helper'

require 'yarr/message'
require 'yarr/database' # TODO : test double

module Yarr
  module Message
    RSpec.describe CommandDispatcher do
      subject do
        klass = described_class
        Class.new { include klass }.new
      end

      it 'handles commands it doesn\'t understand' do
        subject.dispatch('xxx')

        expect(subject.error?).to eql true
        expect(subject.error_message).to eql 'I did not understand command xxx.'
      end

      it 'handles "ri"' do
        subject.dispatch('ri')

        expect(subject.error?).to eql false
        expect(subject.dispatch_method).to eql :ri
        expect(subject.target).to eql ''
      end

      it 'handles "ri aa"' do
        subject.dispatch('ri aa')

        expect(subject.error?).to eql false
        expect(subject.dispatch_method).to eql :ri
        expect(subject.target).to eql 'aa'
      end

      it 'handles "what_is"' do
        subject.dispatch('what_is')

        expect(subject.error?).to eql false
        expect(subject.dispatch_method).to eql :what_is
        expect(subject.target).to eql ''
      end

      it 'handles "what_is aa"' do
        subject.dispatch('what_is aa')

        expect(subject.error?).to eql false
        expect(subject.dispatch_method).to eql :what_is
        expect(subject.target).to eql 'aa'
      end

      it 'handles "list"' do
        subject.dispatch('list')

        expect(subject.error?).to eql false
        expect(subject.dispatch_method).to eql :list
        expect(subject.target).to eql ''
      end

      it 'handles "list aa"' do
        subject.dispatch('list aa')

        expect(subject.error?).to eql false
        expect(subject.dispatch_method).to eql :list
        expect(subject.target).to eql 'aa'
      end
    end

    RSpec.describe Parser do
      it 'raises errror on empty target' do
        expect { subject.parse('') }.to raise_error Parslet::ParseFailed
      end

      it 'raises error on invalid target' do
        expect { subject.parse('@@') }.to raise_error Parslet::ParseFailed
      end

      it 'parses "Class" as class name' do
        expect(subject.parse('Class')).to eq({class_name: 'Class' })
      end

      it 'allows for % meta chars in a class name' do
        expect(subject.parse('Cl%ss')).to eq({class_name: 'Cl%ss' })
      end

      it 'allows for upper case inside a class name' do
        expect(subject.parse('CL%ss')).to eq({class_name: 'CL%ss' })
      end

      it 'parses method as method name' do
        expect(subject.parse('method')).to eq({method_name: 'method' })
      end

      it 'allows for % meta chars in a class name' do
        expect(subject.parse('me%hod')).to eq({method_name: 'me%hod' })
      end

      it 'raises error for upper case inside a method name' do
        expect { subject.parse('mEtHoD') }.to raise_error Parslet::ParseFailed
      end

      it 'parses % as a method' do
        expect(subject.parse('%')).to eq({method_name: '%' })
      end

      it 'parses "Array#size" as instance method' do
        expect(subject.parse('Array#size')).to eq({ instance_method:
                                                   { class_name: 'Array',
                                                     method_name: 'size' }})
      end

      it 'parses "File.size" as class method' do
        expect(subject.parse('File.size')).to eq({ class_method:
                                                   { class_name: 'File',
                                                     method_name: 'size' }})
      end

      it 'needs more examples'
    end

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
