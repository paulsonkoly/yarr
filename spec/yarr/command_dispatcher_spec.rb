require 'spec_helper'
require 'yarr/command_dispatcher'

module Yarr
 RSpec.describe CommandDispatcher do
  subject do
   klass = described_class
   Class.new { include klass }.new
  end

  it 'handles "ast aa"' do
   handler = subject.dispatch({command: 'ast', method_name: 'aa'})

   expect(handler).to be_a Command::AST
  end

  context 'with ri command' do
   it 'handles method names' do
    handler = subject.dispatch({command: 'ri', method_name: 'aa'})

    expect(handler).to be_a Command::RiMethodName
   end

   it 'handles class names' do
    handler = subject.dispatch({command: 'ri', class_name: 'Aa'})

    expect(handler).to be_a Command::RiClassName
   end

   it 'handles instance methods' do
    handler = subject.dispatch({command: 'ri', instance_method: 'Aa'})

    expect(handler).to be_a Command::RiInstanceMethod
   end

   it 'handles class methods' do
    handler = subject.dispatch({command: 'ri', class_method: 'Aa'})

    expect(handler).to be_a Command::RiClassMethod
   end
  end

  context 'with list command' do
   it 'handles method names' do
    handler = subject.dispatch({command: 'list', method_name: 'aa'})

    expect(handler).to be_a Command::ListMethodName
   end

   it 'handles class names' do
    handler = subject.dispatch({command: 'list', class_name: 'Aa'})

    expect(handler).to be_a Command::ListClassName
   end

   it 'handles instance methods' do
    handler = subject.dispatch({command: 'list', instance_method: 'Aa'})

    expect(handler).to be_a Command::ListInstanceMethod
   end

   it 'handles class methods' do
    handler = subject.dispatch({command: 'list', class_method: 'Aa'})

    expect(handler).to be_a Command::ListClassMethod
   end
  end
 end
end
