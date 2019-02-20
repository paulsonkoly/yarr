require 'spec_helper'
require 'yarr/no_irc'
require 'faker'

module Yarr
  RSpec.describe NoIRC do
    let(:no_irc) { subject }

    describe '#user_list' do
      let(:user_list) {  no_irc.user_list }
      describe '#find' do
        it 'returns nil' do
          expect(user_list.find(Faker::Movies::StarWars.character)).to be_nil
        end
      end
    end
  end
end
