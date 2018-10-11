require_relative '../spec_helper'
require 'yarr/message'

module Yarr
  RSpec.describe Message do
    describe '#reply_to' do
      it 'does not reply to commands it doesn\'t understand'
      it 'replies to ri'
      it 'dispatches to #ri'
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
end
