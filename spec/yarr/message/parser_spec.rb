require 'spec_helper'
require 'yarr/message/parser'

module Yarr
  module Message
    RSpec.describe Parser do
      it 'raises errror on empty target' do
        expect { subject.parse('') }.to raise_error Parslet::ParseFailed
      end

      %w[@@ .. // ' " a$ {}].each do |w|
        it "raises error for #{w}" do
          expect { subject.parse(w) }.to raise_error Parslet::ParseFailed
        end
      end

      it 'parses [] as a method' do
        expect(subject.parse('[]')).to eq({method_name: '[]' })
      end

      it 'parses << as a method' do
        expect(subject.parse('<<')).to eq({method_name: '<<' })
      end

      it 'parses size= as a method' do
        expect(subject.parse('size=')).to eq({method_name: 'size=' })
      end

      it 'parses "Class" as class name' do
        expect(subject.parse('Class')).to eq({class_name: 'Class' })
      end

      it 'allows for % meta chars in a class name' do
        expect(subject.parse('Cl%ss')).to eq({class_name: 'Cl%ss' })
      end

      it 'allows for upper case inside a class name' do
        expect(subject.parse('CL%ss')).to eq({class_name: 'CL%ss' })
      end

      it 'parses method as method name' do
        expect(subject.parse('method')).to eq({method_name: 'method' })
      end

      it 'allows for % meta chars in a class name' do
        expect(subject.parse('me%hod')).to eq({method_name: 'me%hod' })
      end

      it 'raises error for upper case inside a method name' do
        expect { subject.parse('mEtHoD') }.to raise_error Parslet::ParseFailed
      end

      it 'parses % as a method' do
        expect(subject.parse('%')).to eq({method_name: '%' })
      end

      it 'parses "Array#size" as instance method' do
        expect(subject.parse('Array#size')).to eq({ instance_method:
                                                    { class_name: 'Array',
                                                      method_name: 'size' }})
      end

      it 'parses "File.size" as class method' do
        expect(subject.parse('File.size')).to eq({ class_method:
                                                   { class_name: 'File',
                                                     method_name: 'size' }})
      end
    end
  end
end
