require 'spec_helper'
require 'yarr/database'
require 'yarr/query/klass'
require 'yarr/query/origin'

module Yarr
  module Query
    RSpec.describe Klass do
      describe '#full_name' do
        context 'when the class is from core' do
          subject do
            described_class.where({
              name: 'Array',
              origin: Origin.where(name: 'core')
            }).first.full_name
          end

          it { is_expected.to eq 'Array' }
        end

        context "when the class isn't from core" do
          subject do
            described_class.where({
              name: 'Array',
              origin: Origin.where(name: 'abbrev')
            }).first.full_name
          end

          it { is_expected.to eq 'Array (abbrev)' }
        end
      end
    end
  end
end
