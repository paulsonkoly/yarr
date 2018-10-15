require 'spec_helper'
require 'yarr/command/base'

module Yarr
  module Command
    RSpec.describe Base do
      let(:ast) { { a: {}, b: { class_name: 'class', method_name: 'method' } } }
      subject { described_class.new(ast) }

      describe '.handle' do
        it 'raises NotImplementedError' do
          expect { subject.handle }.to raise_error(NotImplementedError)
        end
      end

      describe '.klass' do
        it 'returns the klass from the ast' do
          expect(subject.send(:klass)).to eql 'class'
        end
      end

      describe '.method' do
        it 'returns the method from the ast' do
          expect(subject.send(:method)).to eql 'method'
        end
      end
    end
  end
end
