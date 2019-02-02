require 'spec_helper'
require 'yarr/input_parser'

module Yarr
  RSpec.describe InputParser do
    let(:parser) { subject }

    describe 'command' do
      it 'raises error on empty command' do
        expect { parser.parse('') }.to raise_error Parslet::ParseFailed
      end

      it 'raises error on invalid command' do
        expect { parser.parse('xxx') }.to raise_error Parslet::ParseFailed
      end

      it 'parses ri' do
        expect(parser.parse('ri []')[:command]).to eq 'ri'
      end

      it 'parses list' do
        expect(parser.parse('list []')[:command]).to eq 'list'
      end

      it 'parses ast' do
        expect(parser.parse('ast []')[:command]).to eq 'ast'
      end
    end

    describe 'target' do
      it 'raises errror on empty target' do
        expect { parser.parse('ri') }.to raise_error Parslet::ParseFailed
      end

      %w[@@ .. // ' " a$ {}].each do |w|
        it "raises error for #{w}" do
          expect { parser.parse("ri #{w}") }.to raise_error Parslet::ParseFailed
        end
      end

      it 'parses [] as a method' do
        expect(parser.parse('ri []')[:method_name]).to eq '[]'
      end

      it 'parses << as a method' do
        expect(parser.parse('ri <<')[:method_name]).to eq '<<'
      end

      it 'parses size= as a method' do
        expect(parser.parse('ri size=')[:method_name]).to eq 'size='
      end

      it 'parses "Class" as class name' do
        expect(parser.parse('ri Class')[:class_name]).to eq 'Class'
      end

      it 'parses "Array (abbrev)" as a class with origin' do
        expect(parser.parse('ri Array (abbrev)')[:origin_name]).to eq 'abbrev'
      end

      it 'allows for % meta chars in a class name' do
        expect(parser.parse('ri Cl%ss')[:class_name]).to eq 'Cl%ss'
      end

      it 'allows for upper case inside a class name' do
        expect(parser.parse('ri CL%ss')[:class_name]).to eq 'CL%ss'
      end

      it 'parses method as method name' do
        expect(parser.parse('ri method')[:method_name]).to eq 'method'
      end

      it 'allows for % meta chars in a class name' do
        expect(parser.parse('ri me%hod')[:method_name]).to eq 'me%hod'
      end

      it 'raises error for upper case inside a method name' do
        expect do
          parser.parse('ri mEtHoD')
        end.to raise_error Parslet::ParseFailed
      end

      it 'parses % as a method' do
        expect(parser.parse('ri %')[:method_name]).to eq '%'
      end

      it 'parses %x%x as a method' do
        expect(parser.parse('ri %x%x')[:method_name]).to eq '%x%x'
      end

      describe 'unary operator support' do
        it 'parses -@ as a method' do
          expect(parser.parse('ri -@')[:method_name]).to eq '-@'
        end

        it 'parses ~ as a method' do
          expect(parser.parse('ri ~')[:method_name]).to eq '~'
        end
      end

      it 'parses "Array#size" as instance method' do
        ast = parser.parse('ri Array#size')
        expect(ast[:instance_method]).to eq(
          class_name: 'Array',
          method_name: 'size'
        )
      end

      it 'parses "File.size" as class method' do
        ast = parser.parse('ri File.size')
        expect(ast[:class_method]).to eq(
          class_name: 'File',
          method_name: 'size'
        )
      end
    end

    describe 'stuff' do
      it 'parses ,anything$%^&*' do
        ast = parser.parse('ri [],anything$%^&*')
        expect(ast[:stuff]).to eq 'anything$%^&*'
      end
    end
  end
end
