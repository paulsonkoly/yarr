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
=begin
  RSpec.describe Message do
    describe '#reply_to' do
      it 'handles commands it doesn\'t understand' do
        expected_reply = 'I did not understand command xxx.'
        expect(subject.reply_to('xxx')).to eql expected_reply
      end

      it 'replies to "ri"'

      it 'replies to "ri aa"' do
        expect(subject.reply_to('ri aa')).not_to match(/did not understand/)
      end

      it 'dispatches to #ri' do
        subject.reply_to('ri aa')
        expect(handle_ri).to have_been_called
      end

      it 'replies to list'
      it 'dispatches to #list'
    end

    describe '.ri' do
      context 'when message is in the form of Class#method' do
        it 'gives the url'

        context 'when it\'s not found' do
          it 'reports that'
        end
      end

      context 'when message is in the form of Class.method' do
        it 'gives the url'

        context 'when it\'s not found' do
          it 'reports that'
        end
      end

      context 'when message is in the form of Class' do
        it 'gives the url'

        context 'when it\'s not found' do
          it 'reports that'
        end
      end

      context 'when there is multiple name matches' do
        it 'mentions that in the reply'
      end
    end

    describe '.list' do
      it 'lists the info about the asked subject'
    end
  end
=end
  end
end
