require 'spec_helper'
require 'yarr/command/ri'
require 'helpers/not_implemented_helper'

module Yarr
  module Command
    RSpec.describe 'ri command' do
      describe Ri do
        subject do
          described_class.new(class_name: 'Array',
                              method_name: 'size')
        end

        does_not_implement :query
        does_not_implement :target
      end

      describe RiCall do
        subject do
          described_class.new(class_name: 'Array',
                              method_name: 'size')
        end

        does_not_implement :flavour
      end

      describe RiInstanceMethod do
        describe '#handle' do
          subject do
            described_class.new(class_name: 'Array',
                                method_name: 'size').handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
        end
      end

      describe RiClassMethod do
        describe '#handle' do
          subject do
            described_class.new(class_name: 'Array',
                                method_name: 'new').handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*Array.*new} }
        end

        describe '#target' do
          subject do
            described_class.new(class_name: 'Array',
                                method_name: 'new').send :target
          end

          it { is_expected.to eq 'class Array class method new' }
        end
      end

      describe RiClassName do
        describe '#handle' do
          subject do
            described_class.new(class_name: 'Abbrev').handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*abbrev} }

          context 'when there is a hit from core' do
            subject do
              described_class.new(class_name: 'Array').handle
            end

            it { is_expected.to match %r{https://ruby-doc.org/.*Array} }
          end

          context 'with an explicit origin' do
            subject do
              described_class.new(class_name: 'Array',
                                  origin_name: 'abbrev').handle
            end

            let(:long_url) { %r{https://ruby-doc.org/.*abbrev.*/Array.html} }

            it { is_expected.to match(long_url) }
          end
        end

        describe '#target' do
          subject do
            described_class.new(class_name: 'Array').send :target
          end

          it { is_expected.to eq 'class Array' }
        end
      end

      describe RiMethodName do
        describe '#handle' do
          subject do
            described_class.new(method_name: 'size').handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
        end

        describe '#target' do
          subject do
            described_class.new(method_name: 'new').send :target
          end

          it { is_expected.to eq 'method new' }
        end

        describe '#advice' do
          subject do
            described_class.new(method_name: 'new').send :advice
          end

          let(:advice) { 'Use &list new if you would like to see a list' }

          it { is_expected.to eq advice }
        end
      end
    end
  end
end
