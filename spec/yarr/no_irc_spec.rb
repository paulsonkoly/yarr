require 'spec_helper'
require 'yarr/no_irc'
require 'faker'

module Yarr
  RSpec.describe NoIRC do
    describe '#user_list' do
      subject { described_class.user_list }

      it { is_expected.to be_empty }
    end
  end
end
