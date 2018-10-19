require 'spec_helper'
require 'yarr/query/klass'
require 'yarr/query/result'
require 'yarr/database'

module Yarr
  module Query
    module Klass
      RSpec.describe Base do

        describe '.to_s' do
          context 'when origin is core' do
            subject do
              described_class.new('size', 'array.html', 'core')
            end

            it 'returns the name' do
              expect(subject.to_s).to eql 'size'
            end
          end

          context 'when origin is test' do
            subject do
              described_class.new('size', 'array.html', 'test')
            end

            it 'returns the name' do
              expect(subject.to_s).to eql 'size (test)'
            end
          end
        end
      end

      RSpec.describe Strict do
        describe '.query' do
          subject { described_class.query(name: 'Array') }

          before do
            query = double('query')
            allow(DB).to receive(:[]).and_return(query)
            allow(query).to receive(:join).and_return(query)
            allow(query).to receive(:select).and_return(query)
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
            allow(query).to receive(:join).and_return(query)
            allow(query).to receive(:select).and_return(query)
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
