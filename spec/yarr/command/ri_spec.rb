require 'spec_helper'
require 'yarr/command/ri'

module Yarr
  module Command
    RSpec.describe RiInstanceMethod do
      describe '#handle' do
        let(:ast) { Yarr::AST.new(class_name: 'Array',
                                  method_name: 'size') }
        subject { described_class.new(ast).handle }

        it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
      end
    end

    describe RiClassMethod do
      describe '#handle' do
        let(:ast) { Yarr::AST.new(class_name: 'Array',
                                  method_name: 'new')  }
        subject { described_class.new(ast).handle }

        it { is_expected.to match %r{https://ruby-doc.org/.*Array.*new} }
      end

      describe '#target' do
        let(:ast) { Yarr::AST.new(class_name: 'Array',
                                  method_name: 'new') }
        subject { described_class.new(ast).send :target }

        it { is_expected.to eq 'class Array class method new' }
      end
    end

    describe RiClassName do
      describe '#handle' do
        let(:ast) { Yarr::AST.new(class_name: 'Abbrev') }
        subject { described_class.new(ast).handle }

        it { is_expected.to match %r{https://ruby-doc.org/.*abbrev} }

        context 'when there is a hit from core' do
          let(:ast) { Yarr::AST.new(class_name: 'Array') }
          subject { described_class.new(ast).handle }

          it { is_expected.to match %r{https://ruby-doc.org/.*Array} }
        end

        context 'with an explicit origin' do
          let(:ast) { Yarr::AST.new(class_name: 'Array',
                                    origin_name: 'abbrev') }
          subject { described_class.new(ast).handle }

          let(:long_url) { %r{https://ruby-doc.org/.*abbrev.*/Array.html} }

          it { is_expected.to match(long_url) }
        end
      end

      describe '#target' do
        let(:ast) { Yarr::AST.new(class_name: 'Array') }
        subject { described_class.new(ast).send :target }

        it { is_expected.to eq 'class Array' }
      end
    end

    describe RiMethodName do
      describe '#handle' do
        let(:ast) { Yarr::AST.new(method_name: 'size') }
        subject { described_class.new(ast).handle }

        it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
      end

      describe '#target' do
        let(:ast) { Yarr::AST.new(method_name: 'new') }
        subject { described_class.new(ast).send :target }

        it { is_expected.to eq 'method new' }
      end

      describe '#advice' do
        let(:ast) { Yarr::AST.new(method_name: 'new')  }
        subject { described_class.new(ast).send :advice }

        let(:advice) { 'Use &list new if you would like to see a list' }

        it { is_expected.to eq advice }
      end
    end
  end
end
