require 'spec_helper'

module Yarr
  module Message
    RSpec.describe Splitter do
      subject do
        klass = described_class
        Class.new { include klass }.new
      end

      describe '.split' do
        it 'splits the input into command, the ast, and stuff' do
          expect(subject.split('ri Array,phaul')).to eql ['ri', 'Array', 'phaul']
        end
      end
    end
  end
end
