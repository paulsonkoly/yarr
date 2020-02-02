require 'spec_helper'
require 'yarr/database'
require 'yarr/query/method'
require 'yarr/query/klass'

module Yarr
  module Query
    RSpec.describe Method do
      describe '#full_name' do
        subject { _method.full_name }

        context 'when the method is an instance method' do
          let(:_method) { build(:method, flavour: 'instance') }

          it { is_expected.to eq "#{_method.klass.name}##{_method.name}" }
        end

        context 'when the method is a class method' do
          let(:_method) { build(:method, flavour: 'class') }

          it { is_expected.to eq "#{_method.klass.name}.#{_method.name}" }
        end
      end
    end
  end
end
