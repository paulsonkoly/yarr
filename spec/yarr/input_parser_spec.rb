require 'spec_helper'
require 'yarr/input_parser'

module Yarr
  RSpec.describe InputParser do
    let(:parser) { subject }

    describe '#parse' do
      it 'raises error on empty command' do
        expect { parser.parse('') }.to raise_error InputParser::ParseError
      end

      it 'raises error on invalid command' do
        expect { parser.parse('xxx') }.to raise_error InputParser::ParseError
      end

      context 'with ri type commands' do
        it 'parses ri' do
          expect(parser.parse('ri []')[:command]).to eq 'ri'
        end

        it 'parses list' do
          expect(parser.parse('list []')[:command]).to eq 'list'
        end

        it 'parses fake' do
          expect(parser.parse('fake []')[:command]).to eq 'fake'
        end

        it 'raises error on empty target' do
          expect { parser.parse('ri') }.to raise_error InputParser::ParseError
        end

        %w[@@ .. // ' " a$ {}].each do |word|
          it "raises error for #{word}" do
            expect { parser.parse("ri #{word}") }
              .to raise_error InputParser::ParseError
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

        it 'allows for % meta chars in a method name' do
          expect(parser.parse('ri me%hod')[:method_name]).to eq 'me%hod'
        end

        it 'raises error for upper case inside a method name' do
          expect do
            parser.parse('ri mEtHoD')
          end.to raise_error InputParser::ParseError
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

        it 'supports stuff, anything$%^&*' do
          ast = parser.parse('ri [],anything$%^&*')
          expect(ast[:stuff]).to eq 'anything$%^&*'
        end

        it 'parses numbers in class names' do
          ast = parser.parse('ri SHA256')
          expect(ast[:class_name]).to eq 'SHA256'
        end

        it 'parses numbers in method names' do
          ast = parser.parse('ri md5')
          expect(ast[:method_name]).to eq 'md5'
        end

        it 'parses single letter method names' do
          ast = parser.parse('ri x')
          expect(ast[:method_name]).to eq 'x'
        end

        it 'raises parse error for single number method name' do
          expect { parser.parse('ri 5') }.to raise_error InputParser::ParseError
        end
      end

      context 'with evaluate type commands' do
        it 'parses >>1 + 1' do
          expect(parser.parse('>>1 + 1')[:evaluate]).to eq(code: '1 + 1')
        end

        it 'supports ast' do
          expect(parser.parse('ast>> 1 + 1')[:evaluate][:mode]).to eq 'ast'
        end

        it 'supports tok' do
          expect(parser.parse('tok>> 1 + 1')[:evaluate][:mode]).to eq 'tok'
        end

        it 'supports asm' do
          expect(parser.parse('asm>> 1 + 1')[:evaluate][:mode]).to eq 'asm'
        end

        it 'supports lang' do
          expect(parser.parse('20>> 1 + 1')[:evaluate][:lang]).to eq '20'
        end

        it 'supports combination of mode and lang' do
          evaluate = parser.parse('asm20>>1 + 1')[:evaluate]
          expect(evaluate).to include(mode: 'asm', lang: '20', code: '1 + 1')
        end
      end

      context 'with url type commands' do
        it 'parses url' do
          expect(parser.parse('url something')[:url_evaluate])
            .to eq(url: 'something')
        end

        it 'supports stuff' do
          expect(parser.parse('url something, phaul')[:stuff]).to eq 'phaul'
        end
      end

      context 'with no argument commands' do
        it 'parses renick' do
          expect(parser.parse('renick')[:command]).to eq('renick')
        end

        it 'parses ops' do
          expect(parser.parse('ops')[:command]).to eq('ops')
        end
      end

      context 'with fact commands' do
        it 'parses fact pizza' do
          expect(parser.parse('fact pizza'))
            .to be_an_ast_with(command: 'fact', name: 'pizza')
        end

        it 'supports stuff' do
          expect(parser.parse('fact pizza, phaul'))
            .to be_an_ast_with(command: 'fact', name: 'pizza', stuff: 'phaul')
        end

        it 'has an alias as ?' do
          expect(parser.parse('?pizza, phaul'))
            .to be_an_ast_with(command: 'fact', name: 'pizza', stuff: 'phaul')
        end

        context 'with add sub command' do
          it 'parses fact pizza' do
            expect(parser.parse('fact add pizza no pizza today'))
              .to be_an_ast_with(command: 'fact',
                                 sub_command: 'add',
                                 name: 'pizza',
                                 content: 'no pizza today')
          end

          it 'has an alias as mk' do
            expect(parser.parse('? mk pizza no pizza today'))
              .to be_an_ast_with(command: 'fact',
                                 sub_command: 'add',
                                 name: 'pizza',
                                 content: 'no pizza today')
          end

          it 'aliases add to mk' do
            expect(parser.parse('? mk pizza no pizza today'))
              .to be_an_ast_with(command: 'fact',
                                 sub_command: 'add',
                                 name: 'pizza',
                                 content: 'no pizza today')
          end
        end

        context 'with remove sub command' do
          it 'parses fact remove pizza' do
            expect(parser.parse('fact remove pizza'))
              .to be_an_ast_with(command: 'fact',
                                 sub_command: 'remove',
                                 name: 'pizza')
          end

          it 'has an alias as ?' do
            expect(parser.parse('? remove pizza'))
              .to be_an_ast_with(command: 'fact',
                                 sub_command: 'remove',
                                 name: 'pizza')
          end

          it 'aliases remove to to rm' do
            expect(parser.parse('? rm pizza'))
              .to be_an_ast_with(command: 'fact',
                                 sub_command: 'remove',
                                 name: 'pizza')
          end
        end
      end
    end
  end
end
