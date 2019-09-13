require 'spec_helper'
require 'yarr/command/base'

module Yarr
  module Command
    RSpec.describe Base do
      let(:ast) { 'invalid' }

      describe '#handle' do
        let(:command) { described_class.new(ast: ast) }

        it 'handles everything' do
          expect(command.handle)
            .to eq "Yarr::Command::Base doesn't know how to handle invalid"
        end
      end
    end
  end
end
