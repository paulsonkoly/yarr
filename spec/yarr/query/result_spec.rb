require 'spec_helper'
require 'yarr/query/result'

module Yarr
  module Query
    RSpec.describe Result do
      subject { described_class.new([1, 2, 3], -> x { 2 * x }) }

      it { is_expected.to be_a Result }

      describe '#each' do
        it 'yields the transformed elements' do
          expect { |b| subject.each(&b) }.to yield_successive_args(2, 4, 6)
        end
      end
    end
  end
end
