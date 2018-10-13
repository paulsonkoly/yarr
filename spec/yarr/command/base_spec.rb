require 'spec_helper'

module Yarr
  module Command
    RSpec.describe Base do
      subject { described_class.new(double('ast')) }

      describe '.handle' do
        it 'raises NotImplementedError' do
          expect { subject.handle }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
