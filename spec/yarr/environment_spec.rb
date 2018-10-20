require 'spec_helper'
require 'yarr/environment'

module Yarr
  RSpec.describe Environment do
    context 'with YARR_TEST set to 1' do
      it { is_expected.to be_test }
      it { is_expected.not_to be_production }
    end

    context 'with TEST unset' do
      before { ENV.delete('YARR_TEST') }
      # we need to restore this for other tests
      after { ENV['YARR_TEST'] = '1' }

      it { is_expected.not_to be_test }
      it { is_expected.to be_production }
    end
  end
end
