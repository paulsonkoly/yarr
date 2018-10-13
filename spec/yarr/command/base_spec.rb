require 'spec_helper'

module Yarr
  module Command
    RSpec.describe Base do
      describe '.handle' do
        it 'raises NotImplementedError' do
          expect { subject.handle({}) }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
