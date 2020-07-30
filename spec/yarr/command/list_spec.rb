# frozen_string_literal: true

require 'spec_helper'
require 'yarr/command/list'

module Yarr
  module Command
    RSpec.describe 'list command' do
      let(:ast) { Yarr::AST.new(class_name: '%', method_name: '%') }
      let(:klasses) do
        [build(:klass, name: 'Array'),
         build(:klass, name: 'Array', origin: build(:origin, name: 'abbrev'))]
      end
      let(:methods) do
        [build(:method, flavour: 'instance', name: 'size', klass: klasses[0]),
         build(:method,
               flavour: 'instance',
               name: 'abbrev',
               klass: klasses[1],
               origin: build(:origin, name: 'abbrev'))]
      end
      let(:class_methods) do
        [build(:method, flavour: 'class', name: 'new', klass: klasses[0])]
      end

      describe ListInstanceMethod do
        before do
          allow(Query::Method).to receive(:where).and_return(methods)
        end

        describe '#handle' do
          subject { described_class.new(ast: ast).handle }

          it { is_expected.to eq 'Array#size, Array#abbrev' }
        end

        describe '#target' do
          subject { described_class.new(ast: ast).send :target }

          it { is_expected.to eq 'instance method % on %' }
        end
      end

      describe ListClassMethod do
        before do
          allow(Query::Method).to receive(:where).and_return(class_methods)
        end

        describe '#handle' do
          subject { described_class.new(ast: ast).handle }

          let(:ast) { Yarr::AST.new(class_name: 'Arr%', method_name: 'n%') }

          it { is_expected.to eq 'Array.new' }
        end
      end

      describe ListClassName do
        before do
          allow(Query::Klass).to receive(:where).and_return(klasses)
        end

        describe '#handle' do
          subject { described_class.new(ast: ast).handle }

          let(:ast) { Yarr::AST.new(class_name: 'Array') }

          it { is_expected.to eq 'Array, Array (abbrev)' }
        end

        describe '#target' do
          subject { described_class.new(ast: ast).send :target }

          it { is_expected.to eq 'class %' }
        end
      end

      describe ListMethodName do
        before do
          allow(Query::Method).to receive(:where).and_return([methods[0]])
        end

        describe '#handle' do
          subject { described_class.new(ast: ast).handle }

          let(:ast) { Yarr::AST.new(method_name: 'si%') }

          it { is_expected.to eq 'Array#size' }
        end

        describe '#target' do
          subject { described_class.new(ast: ast).send :target }

          it { is_expected.to eq 'method %' }
        end
      end
    end
  end
end
