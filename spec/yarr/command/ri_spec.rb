# frozen_string_literal: true

require 'spec_helper'
require 'yarr/command/ri'

RSpec.describe Yarr::Command::Ri do
  let(:abbrev) { build(:origin, name: 'abbrev') }
  let(:klasses) do
    [build(:klass, name: 'Array'),
     build(:klass, name: 'Array', origin: abbrev),
     build(:klass,
           name: 'BigDecimal',
           origin: build(:origin, name: 'bigdecimal')),
     build(:klass, name: 'Abbrev', flavour: 'module', origin: abbrev)]
  end
  let(:methods) do
    [build(:method, flavour: 'instance', name: 'size', klass: klasses[0]),
     build(:method,
           flavour: 'instance',
           name: 'abbrev',
           klass: klasses[1],
           origin: abbrev)]
  end
  let(:class_methods) do
    [build(:method, flavour: 'class', name: 'new', klass: klasses[0])]
  end

  describe Yarr::Command::RiInstanceMethod do
    describe '#handle' do
      subject { described_class.new(ast: ast).handle }

      before do
        allow(Yarr::Query::Method).to receive(:where).and_return([methods[0]])
      end

      let(:ast) do
        Yarr::AST.new(class_name: 'Array',
                      method_name: 'size')
      end

      it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
    end
  end

  describe Yarr::Command::RiClassMethod do
    before do
      allow(Yarr::Query::Method).to receive(:where).and_return(class_methods)
    end

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

  describe Yarr::Command::RiClassName do
    describe '#handle' do
      subject { described_class.new(ast: ast).handle }

      context 'with a module name from a non-core origin' do
        before do
          allow(Yarr::Query::Klass).to receive(:where).and_return(dataset)
        end

        let(:ast) { Yarr::AST.new(class_name: 'Abbrev') }
        let(:dataset) { class_double(Yarr::Query::Klass, all: [klasses[1]]) }

        it { is_expected.to match %r{https://ruby-doc.org/.*abbrev} }
      end

      context 'when there is a hit from core' do
        before do
          allow(Yarr::Query::Klass).to receive(:where).and_return(dataset)
        end

        let(:dataset) { class_double(Yarr::Query::Klass, all: klasses) }
        let(:ast) { Yarr::AST.new(class_name: 'Array') }

        it { is_expected.to match %r{https://ruby-doc.org/.*Array} }
      end

      context 'with an explicit origin' do
        before do
          allow(Yarr::Query::Klass).to receive(:where).and_return(dataset)
        end

        let(:ast) do
          Yarr::AST.new(class_name: 'Array',
                        origin_name: 'abbrev')
        end
        let(:dataset) { class_double(Yarr::Query::Klass, all: [klasses[1]]) }
        let(:long_url) { %r{https://ruby-doc.org/.*abbrev.*/Array.html} }

        it { is_expected.to match(long_url) }
      end

      context 'when there are multiple choices,' \
              ' but origin name is the lower case class name' do
        subject { described_class.new(ast: ast).handle }

        before do
          allow(Yarr::Query::Klass).to receive(:where).and_return(dataset)
        end

        let(:dataset) { class_double(Yarr::Query::Klass, all: [klasses[2]]) }
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

  describe Yarr::Command::RiMethodName do
    describe '#handle' do
      subject { described_class.new(ast: ast).handle }

      before do
        allow(Yarr::Query::Method).to receive(:where).and_return(methods[0..0])
      end

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
