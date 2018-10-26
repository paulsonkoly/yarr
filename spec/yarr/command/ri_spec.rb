require 'spec_helper'
require 'yarr/command/ri'
require 'helpers/not_implemented_helper'

module Yarr
  module Command
    RSpec.describe 'ri command' do
      describe Ri do
        subject do
          described_class.new({
            class_name: 'Array',
            method_name: 'size'
          })
        end

        does_not_implement :query
        does_not_implement :target
        does_not_implement :advice
      end

      describe RiCall do
        subject do
          described_class.new({
            class_name: 'Array',
            method_name: 'size'
          })
        end

        does_not_implement :flavour
      end


      describe RiInstanceMethod do
        describe '#handle' do
          subject do
            described_class.new({
              class_name: 'Array',
              method_name: 'size'
            }).handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }
        end
      end

      describe RiClassMethod do
        describe '#handle' do
          subject do
            described_class.new({
              class_name: 'Array',
              method_name: 'new'
            }).handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*Array.*new} }

          context 'when nothing is found' do
            subject do
              described_class.new({
                class_name: 'NonExistent',
                method_name: 'new'
              }).handle
            end

            it { is_expected.to eq('Found no entry that matches class NonExistent class method new') }
          end

          context 'when multiple are found' do
            subject do
              described_class.new({
                class_name: 'String',
                method_name: 'new'
              }).handle
            end

            it { is_expected.to eq('I found 2 entries matching class String class method new. ') }
          end
        end
      end

      describe RiClassName do
        describe '#handle' do
          subject do
            described_class.new(class_name: 'Abbrev').handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*abbrev} }

          context 'when nothing is found' do
            subject do
              described_class.new(class_name: 'NonExistent').handle
            end

            it { is_expected.to eq('Found no entry that matches class NonExistent') }
          end

          context 'when there is a hit from core' do
            subject do
              described_class.new(class_name: 'Array').handle
            end

            it { is_expected.to match %r{https://ruby-doc.org/.*Array} }
          end

          context 'with an explicit origin' do
            subject do
              described_class.new({
                class_name: 'Array',
                origin_name: 'abbrev'
              }).handle
            end

            it { is_expected.to match %r{https://ruby-doc.org/.*abbrev.*/Array.html} }
          end
        end
      end

      describe RiMethodName do
        describe '#handle' do
          subject do
            described_class.new(method_name: 'size').handle
          end

          it { is_expected.to match %r{https://ruby-doc.org/.*Array.*size} }

          context 'when nothing is found' do
            subject do
              described_class.new(method_name: 'non_existent').handle
            end

            it { is_expected.to eq('Found no entry that matches method non_existent') }
          end

          context 'when there are multiple hits' do
            subject do
              described_class.new(method_name: 'new').handle
            end

            it { is_expected.to match(/Use &list new if you would like to see a list/) }
          end
        end
      end
    end
  end
end
