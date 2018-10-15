require 'spec_helper'
require 'yarr/command/what_is'

module Yarr
  module Command
    RSpec.describe WhatIs do
      let(:ast) { { some_ast: {deep: 1} } }

      describe '#handle' do
        subject { WhatIs.new(ast).handle }

        it { is_expected.to start_with('It\'s a(n) ') }
        it { is_expected.to match(/some ast/) }
      end
    end
  end
end
