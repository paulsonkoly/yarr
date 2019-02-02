require 'spec_helper'
require 'yarr/database'
require 'yarr/query/method'
require 'yarr/query/klass'

module Yarr
  module Query
    RSpec.describe Method do
      describe '#full_name' do
        context 'when the method is an instance method' do
          subject do
            described_class.where(
              name: 'size',
              klass: Klass.where(name: 'Array')
            ).first.full_name
          end

          it { is_expected.to eq 'Array#size' }
        end

        context 'when the method is a class method' do
          subject do
            described_class.where(
              name: 'new',
              klass: Klass.where(name: 'Array')
            ).first.full_name
          end

          it { is_expected.to eq 'Array.new' }
        end
      end
    end
  end
end
