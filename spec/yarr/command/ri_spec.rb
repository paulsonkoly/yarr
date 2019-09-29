require 'spec_helper'
require 'yarr/command/ri'

module Yarr
  module Command
    RSpec.describe RiInstanceMethod do
      describe '#handle' do
        subject { described_class.new(ast: ast).handle }

        let(:ast) do
          Yarr::AST.new(class_name: 'Array',
                        method_name: 'size')
        end

        it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
      end
    end

    describe RiClassMethod do
      describe '#handle' do
        subject { described_class.new(ast: ast).handle }

        let(:ast) do
          Yarr::AST.new(class_name: 'Array',
                        method_name: 'new')
        end

        it { is_expected.to match %r{https://ruby-doc.org/.*Array.*new} }
      end

      describe '#target' do
        subject { described_class.new(ast: ast).send :target }

        let(:ast) do
          Yarr::AST.new(class_name: 'Array',
                        method_name: 'new')
        end

        it { is_expected.to eq 'class Array class method new' }
      end
    end

    describe RiClassName do
      describe '#handle' do
        subject { described_class.new(ast: ast).handle }

        let(:ast) { Yarr::AST.new(class_name: 'Abbrev') }

        it { is_expected.to match %r{https://ruby-doc.org/.*abbrev} }

        context 'when there is a hit from core' do
          subject { described_class.new(ast: ast).handle }

          let(:ast) { Yarr::AST.new(class_name: 'Array') }

          it { is_expected.to match %r{https://ruby-doc.org/.*Array} }
        end

        context 'with an explicit origin' do
          subject { described_class.new(ast: ast).handle }

          let(:ast) do
            Yarr::AST.new(class_name: 'Array',
                          origin_name: 'abbrev')
          end

          let(:long_url) { %r{https://ruby-doc.org/.*abbrev.*/Array.html} }

          it { is_expected.to match(long_url) }
        end

        context 'when there are multiple choices but origin name is the lower case class name' do
          subject { described_class.new(ast: ast).handle }

          let(:ast) { Yarr::AST.new(class_name: 'BigDecimal') }

          let(:long_url) { %r{https://ruby-doc.org/.*/BigDecimal.html} }

          it { is_expected.to match(long_url) }
        end
      end

      describe '#target' do
        subject { described_class.new(ast: ast).send :target }

        let(:ast) { Yarr::AST.new(class_name: 'Array') }

        it { is_expected.to eq 'class Array' }
      end
    end

    describe RiMethodName do
      describe '#handle' do
        subject { described_class.new(ast: ast).handle }

        let(:ast) { Yarr::AST.new(method_name: 'size') }

        it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
      end

      describe '#target' do
        subject { described_class.new(ast: ast).send :target }

        let(:ast) { Yarr::AST.new(method_name: 'new') }

        it { is_expected.to eq 'method new' }
      end

      describe '#advice' do
        subject { described_class.new(ast: ast).send :advice }

        let(:ast) { Yarr::AST.new(method_name: 'new') }

        let(:advice) { 'Use &list new if you would like to see a list' }

        it { is_expected.to eq advice }
      end
    end
  end
end
