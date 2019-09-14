require 'spec_helper'
require 'yarr/message/truncator'

module Yarr
  module Message
    RSpec.describe Truncator do
      let(:truncator) { described_class }

      let(:short) do
        Faker::Lorem.paragraph_by_chars(Truncator::MAX_LENGTH - 10)
      end
      let(:long) do
        Faker::Lorem.paragraph_by_chars(Truncator::MAX_LENGTH + 10)
      end

      describe '.truncate' do
        context 'with short message' do
          it 'leaves the message untuched' do
            expect(truncator.truncate(short)).to eq short
          end
        end

        context 'with long message' do
          it 'truncates to length' do
            expect(truncator.truncate(long).length)
              .to be <= Truncator::MAX_LENGTH
          end

          it 'ends with ...' do
            expect(truncator.truncate(long)).to end_with('...')
          end

          it "doesn't change the original string" do
            expect { truncator.truncate(long) }.not_to change(long, :itself)
          end

          context 'without natural break point' do
            it 'cuts the message to max length' do
              expect(truncator.truncate('a' * 1000))
                .to have_attributes(length: Truncator::MAX_LENGTH)
            end
          end
        end

        context 'with multi-line message' do
          it 'starts with the first line' do
            expect(truncator.truncate("a\nb")).to start_with 'a'
          end

          it 'drops content from the end of the first line' do
            expect(truncator.truncate("a\nb")).not_to include "\n"
          end

          context 'if there is no natural break point' do
            it 'cuts the message to max length' do
              expect(truncator.truncate('a' * 1000))
                .to have_attributes(length: Truncator::MAX_LENGTH)
            end
          end

          it 'ends with ...' do
            expect(truncator.truncate("a\nb")).to end_with('...')
          end
        end
      end
    end
  end
end
