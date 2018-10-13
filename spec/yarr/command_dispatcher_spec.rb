require 'spec_helper'
require 'byebug'

module Yarr
  RSpec.describe CommandDispatcher do
    subject do
      klass = described_class
      Class.new { include klass }.new
    end

    it 'handles commands it doesn\'t understand' do
      subject.dispatch('xxx', {})

      expect(subject.error?).to eql true
      expect(subject.error_message).to eql 'I did not understand command xxx.'
    end

    it 'handles "ri aa"' do
      handler = subject.dispatch('ri', { method_name: 'aa' })

      expect(subject.error?).to eql false
      expect(handler).to be_an Command::Ri
    end

    it 'handles "what_is aa"' do
      handler = subject.dispatch('what_is', { method_name: 'aa' })

      expect(subject.error?).to eql false
      expect(handler).to be_an Command::WhatIs
    end

    it 'handles "list aa"' do
      handler = subject.dispatch('list', { method_name: 'aa' })

      expect(subject.error?).to eql false
      expect(handler).to be_an Command::List
    end

    it 'needs examples for AST matching'
  end
end
