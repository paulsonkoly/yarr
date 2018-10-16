require 'spec_helper'
require 'yarr/command_dispatcher'

module Yarr
  RSpec.describe CommandDispatcher do
    subject do
      klass = described_class
      Class.new { include klass }.new
    end

    it 'handles commands it doesn\'t understand' do
      handler = subject.dispatch('xxx', {})

      expect(handler).to be_nil
      expect(subject.error_message).to eql 'I did not understand command xxx.'
    end

    it 'handles "what_is aa"' do
      handler = subject.dispatch('what_is', { method_name: 'aa' })

      expect(handler).to be_an Command::WhatIs
    end

    context 'with ri command' do
      it 'handles method names' do
        handler = subject.dispatch('ri', { method_name: 'aa' })

        expect(handler).to be_an Command::RiMethodName
      end

      it 'handles class names' do
        handler = subject.dispatch('ri', { class_name: 'Aa' })

        expect(handler).to be_an Command::RiClassName
      end

      it 'handles instance methods' do
        handler = subject.dispatch('ri', { instance_method: 'Aa' })

        expect(handler).to be_an Command::RiInstanceMethod
      end

      it 'handles class methods' do
        handler = subject.dispatch('ri', { class_method: 'Aa' })

        expect(handler).to be_an Command::RiClassMethod
      end
    end

    context 'with list command' do
      it 'handles method names' do
        handler = subject.dispatch('list', { method_name: 'aa' })

        expect(handler).to be_an Command::ListMethodName
      end

      it 'handles class names' do
        handler = subject.dispatch('list', { class_name: 'Aa' })

        expect(handler).to be_an Command::ListClassName
      end

      it 'handles instance methods' do
        handler = subject.dispatch('list', { instance_method: 'Aa' })

        expect(handler).to be_an Command::ListInstanceMethod
      end

      it 'handles class methods' do
        handler = subject.dispatch('list', { class_method: 'Aa' })

        expect(handler).to be_an Command::ListClassMethod
      end
    end
  end
end
