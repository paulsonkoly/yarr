# frozen_string_literal: true

require 'spec_helper'
require 'yarr/no_irc'
require 'faker'

RSpec.describe Yarr::NoIRC do
  describe '#user_list' do
    subject { described_class.user_list }

    it { is_expected.to an_instance_of Yarr::NoIRC::UserList }
  end

  describe '#nick=' do
    it { is_expected.to respond_to(:nick=) }

    it 'accepts arguments' do
      expect { subject.nick = 'nick' }.not_to raise_error
    end
  end

  describe '#irc' do
    subject { described_class.irc }

    it { is_expected.to be_falsey }
  end

  describe 'User' do
    subject(:user) { described_class::User.new }

    it 'has attributes of a null object' do
      expect(user).to match(an_object_having_attributes(nick: 'no user', host_unsynced: '', online?: false))
    end
  end

  describe 'UserList' do
    subject(:userlist) { described_class::UserList.new }

    it { is_expected.to be_empty }

    describe '#find' do
      it 'is nil' do
        expect(userlist.find('any')).to be_nil
      end
    end
  end
end
