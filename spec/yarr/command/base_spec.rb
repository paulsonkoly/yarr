require 'spec_helper'
require 'yarr/command/base'
require 'helpers/not_implemented_helper'

module Yarr
  module Command
    RSpec.describe Base do
      let(:ast) { { a: {}, b: { class_name: 'class', method_name: 'method' } } }
      subject { described_class.new(ast) }

      does_not_implement :handle

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
