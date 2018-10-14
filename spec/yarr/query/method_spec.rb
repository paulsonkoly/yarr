require 'spec_helper'

module Yarr
  module Query
    module Method
      RSpec.describe Base do
        subject do
          described_class.new('size', 'size-i-method.html', 'instance', 13)
        end

        describe '.to_s' do
          it 'returns the name' do
            expect(subject.to_s).to eql 'size'
          end
        end
      end

      RSpec.describe Strict do
        describe '.query' do
          subject { described_class.query(name: 'size') }

          before do
            query = double('query')
            allow(DB).to receive(:[]).and_return(query)
            allow(query).to receive(:where).and_return([{name: 'size'}])
          end

          it { is_expected.to be_a Result }

          it 'has one element' do
            expect(subject.count).to eql 1
          end

          it "has 'size'" do
            expect(subject.first.name).to eql 'size'
          end
        end
      end

      RSpec.describe Like do
        describe '.query' do
          subject { described_class.query(name: 'si%') }

          before do
            query = double('query')
            allow(DB).to receive(:[]).and_return(query)
            allow(query).to receive(:join).and_return(query)
            allow(query).to receive(:select).and_return(query)
            allow(query).to receive(:where).and_return([{class_name: 'Array', method_name: 'size', method_flavour: 'instance'}])
          end

          it { is_expected.to be_a Result }

          it 'has one element' do
            expect(subject.count).to eql 1
          end

          it "has 'Array'" do
            expect(subject.first.to_s).to eql 'Array#size'
          end
        end
      end
    end
  end
end
