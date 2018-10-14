require 'spec_helper'

module Yarr
  module Query
    module KlassAndMethod
      RSpec.describe KlassAndMethod do
        let(:klass) { Klass::Base.new('Array', 'array.html') }
        let(:imethod) do
          Method::Base.new('size', 'array-i-size.html', 'instance', 10)
        end
        let(:cmethod) do
          Method::Base.new('size', 'array-i-size.html', 'class', 10)
        end


        describe Base do
          describe '.to_s' do
            context 'with instance method' do
              subject { described_class.new(klass, imethod) }

              it 'returns "Array#size"' do
                expect(subject.to_s).to eql 'Array#size'
              end
            end

            context 'with class method' do
              subject { described_class.new(klass, cmethod) }

              it 'returns "Array.size"' do
                expect(subject.to_s).to eql 'Array.size'
              end
            end
          end
        end

        describe Strict do
          describe '.query' do
            subject do
              described_class.query(method: 'size',
                                    klass: 'Array',
                                    flavour: 'instance')
            end

            before do
              query = double('query')
              allow(DB).to receive(:[]).and_return(query)
              allow(query).to receive(:join).and_return(query)
              allow(query).to receive(:select).and_return(query)
              allow(query).to receive(:where).and_return([{method_name: 'size'}])
            end

            it { is_expected.to be_a Result }

            it 'has one element' do
              expect(subject.count).to eql 1
            end

            it "has 'Array'" do
              expect(subject.first.method.name).to eql 'size'
            end
          end
        end

        describe Like do
          describe '.query' do
            subject do
              described_class.query(method: 'si%',
                                    klass: 'Array',
                                    flavour: 'instance')
            end

            before do
              query = double('query')
              allow(DB).to receive(:[]).and_return(query)
              allow(query).to receive(:join).and_return(query)
              allow(query).to receive(:select).and_return(query)
              allow(query).to receive(:where).and_return([{method_name: 'size'}])
            end

            it { is_expected.to be_a Result }

            it 'has one element' do
              expect(subject.count).to eql 1
            end

            it "has 'Array'" do
              expect(subject.first.method.name).to eql 'size'
            end
          end
        end
      end
    end
  end
end
