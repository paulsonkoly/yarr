require 'spec_helper'
require 'yarr/no_irc'

module Yarr
  RSpec.describe NoIRC do
    let(:no_irc) { subject }

    describe '#user_list' do
      it 'is an empty Array' do
        expect(no_irc.user_list).to eq []
      end
    end
  end
end
