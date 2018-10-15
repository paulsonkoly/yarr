require 'spec_helper'
require 'yarr/query/klass'
require 'yarr/query/result'
require 'yarr/database'

module Yarr
  module Query
    module Klass
      RSpec.describe Base do
        subject do
          described_class.new('size', 'array.html')
        end

        describe '.to_s' do
          it 'returns the name' do
            expect(subject.to_s).to eql 'size'
          end
        end
      end

      RSpec.describe Strict do
        describe '.query' do
          subject { described_class.query(name: 'Array') }

          before do
            query = double('query')
            allow(DB).to receive(:[]).and_return(query)
            allow(query).to receive(:where).and_return([{name: 'Array'}])
          end

          it { is_expected.to be_a Result }

          it 'has one element' do
            expect(subject.count).to eql 1
          end

          it "has 'Array'" do
            expect(subject.first.name).to eql 'Array'
          end
        end
      end

      RSpec.describe Like do
        describe '.query' do
          subject { described_class.query(name: 'Ar%') }

          before do
            query = double('query')
            allow(DB).to receive(:[]).and_return(query)
            allow(query).to receive(:where).and_return([{name: 'Array'}])
          end

          it { is_expected.to be_a Result }

          it 'has one element' do
            expect(subject.count).to eql 1
          end

          it "has 'Array'" do
            expect(subject.first.name).to eql 'Array'
          end
        end
      end
    end
  end
end
