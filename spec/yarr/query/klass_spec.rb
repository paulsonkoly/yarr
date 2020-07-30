# frozen_string_literal: true

require 'spec_helper'
require 'yarr/database'
require 'yarr/query/klass'
require 'yarr/query/origin'

RSpec.describe Yarr::Query::Klass do
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

  describe '#same_origin?' do
    subject { klass.same_origin? }

    context 'when the origin name matches the class name' do
      let(:klass) { build :klass, name: 'Array', origin: build(:origin, name: 'array') }

      it { is_expected.to be_truthy }
    end

    context 'when the origin name does not match the class name' do
      let(:klass) { build :klass, name: 'array', origin: build(:origin, name: 'core') }

      it { is_expected.to be_falsey }
    end
  end
end
