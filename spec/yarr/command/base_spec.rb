require 'spec_helper'
require 'yarr/command/base'

module Yarr
  module Command
    RSpec.describe Base do
      let(:ast) do
        Yarr::AST.new(a: {}, b: { class_name: 'class', method_name: 'method' })
      end
      let(:command) { described_class.new(ast) }

      describe '.klass' do
        it 'returns the klass from the ast' do
          expect(command.send(:klass)).to eql 'class'
        end
      end

      describe '.method' do
        it 'returns the method from the ast' do
          expect(command.send(:method)).to eql 'method'
        end
      end
    end
  end
end
