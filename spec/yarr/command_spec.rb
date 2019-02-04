require 'spec_helper'
require 'yarr/command'

module Yarr
  RSpec.describe Command do
    let(:dispatcher) { subject }

    it 'handles "ast aa"' do
      handler = dispatcher.for_ast(command: 'ast', method_name: 'aa')

      expect(handler).to be_a Command::AST
    end

    context 'with ri command' do
      it 'handles method names' do
        handler = dispatcher.for_ast(command: 'ri', method_name: 'aa')

        expect(handler).to be_a Command::RiMethodName
      end

      it 'handles class names' do
        handler = dispatcher.for_ast(command: 'ri', class_name: 'Aa')

        expect(handler).to be_a Command::RiClassName
      end

      it 'handles instance methods' do
        handler = dispatcher.for_ast(command: 'ri', instance_method: 'Aa')

        expect(handler).to be_a Command::RiInstanceMethod
      end

      it 'handles class methods' do
        handler = dispatcher.for_ast(command: 'ri', class_method: 'Aa')

        expect(handler).to be_a Command::RiClassMethod
      end
    end

    context 'with list command' do
      it 'handles method names' do
        handler = dispatcher.for_ast(command: 'list', method_name: 'aa')

        expect(handler).to be_a Command::ListMethodName
      end

      it 'handles class names' do
        handler = dispatcher.for_ast(command: 'list', class_name: 'Aa')

        expect(handler).to be_a Command::ListClassName
      end

      it 'handles instance methods' do
        handler = dispatcher.for_ast(command: 'list', instance_method: 'Aa')

        expect(handler).to be_a Command::ListInstanceMethod
      end

      it 'handles class methods' do
        handler = dispatcher.for_ast(command: 'list', class_method: 'Aa')

        expect(handler).to be_a Command::ListClassMethod
      end
    end
    context 'with no matching real command' do
      it 'defaults to Null' do
        handler = dispatcher.for_ast(command: 'xxx')

        expect(handler).to be_a Command::Null
      end
    end
  end
end
