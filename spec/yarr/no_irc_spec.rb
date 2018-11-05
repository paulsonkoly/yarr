require 'spec_helper'
require 'yarr/no_irc'

module Yarr
  RSpec.describe NoIRC do
    describe '#user_list' do
      it 'is an empty Array' do
        expect(subject.user_list).to eq []
      end
    end
  end
end
