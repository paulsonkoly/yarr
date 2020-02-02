require 'spec_helper'
require 'yarr/database'
require 'yarr/query/klass'
require 'yarr/query/origin'

module Yarr
  module Query
    RSpec.describe Klass do
      describe '#full_name' do
        subject { klass.full_name }

        context 'when the class is from core' do
          let(:klass) { build :klass, origin: build(:origin, name: 'core') }

          it { is_expected.to eq klass.name }
        end

        context "when the class isn't from core" do
          let(:klass) { build :klass, origin: build(:origin, name: 'abbrev') }

          it { is_expected.to eq "#{klass.name} (abbrev)" }
        end
      end
    end
  end
end
