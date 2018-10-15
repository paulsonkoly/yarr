require 'spec_helper'
require 'yarr/environment'

module Yarr
  RSpec.describe Environment do
    context 'with TEST set to 1' do
      before { ENV['TEST']='1' }

      it { is_expected.to be_test }
      it { is_expected.not_to be_production }
    end

    context 'with TEST unset' do
      before { ENV.delete('TEST') }

      it { is_expected.not_to be_test }
      it { is_expected.to be_production }
    end
  end
end
