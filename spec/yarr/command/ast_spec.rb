require 'spec_helper'
require 'yarr/command/ast'

module Yarr
  module Command
    RSpec.describe AST do
      let(:ast) { { some_ast: { deep: 1 } } }

      describe '#handle' do
        subject { AST.new(ast).handle }

        it { is_expected.to eq ast.inspect }
      end
    end
  end
end
