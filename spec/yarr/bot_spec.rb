require 'spec_helper'

require 'yarr/bot'

module Yarr
  RSpec.describe Bot do
    describe '.reply_to' do
      context 'with valid command' do
        before do
          subject.instance_variable_set(:@parser, double('parser', parse: { }))
        end

        it 'returns the result from handler' do
          allow(subject).to receive(:handler)
            .and_return(double('handler', handle: 'hello'))

          expect(subject.reply_to('list')).to eq 'hello'
        end
      end

      context 'with invalid command' do
        it 'returns an error message' do
          expect(subject.reply_to('xxx')).to eq subject.error_message
        end
      end

      context 'with stuff attached' do
        it 'appends stuff at the end' do
          expect(subject.reply_to('list blah, phaul')).to end_with(' , phaul')
        end
      end
    end
  end
end
