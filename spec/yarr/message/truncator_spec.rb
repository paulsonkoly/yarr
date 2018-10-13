require 'spec_helper'

module Yarr
  module Message
    RSpec.describe Truncator do
      let (:short) { Faker::Lorem.paragraph_by_chars(Truncator::MAX_LENGTH - 10) }
      let (:long) { Faker::Lorem.paragraph_by_chars(Truncator::MAX_LENGTH + 10) }

      describe '.truncate' do
        context 'with short message' do
          it 'leaves the message untuched' do
            expect(subject.truncate(short)).to eq short
          end
        end

        context 'with long message' do
          it 'truncates to length' do
            expect(subject.truncate(long).length).to be <= Truncator::MAX_LENGTH
          end

          it 'ends with ...' do
            expect(subject.truncate(long)).to end_with('...')
          end
        end
      end
    end
  end
end
