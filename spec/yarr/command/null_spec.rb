require 'spec_helper'
require 'yarr/command/null'

module Yarr
  module Command
    RSpec.describe Null do
      let(:ast) { 'invalid' }

      describe '#handle' do
        let(:command) { described_class.new(ast) }

        it 'handles everything' do
          expect(command.handle).to eq 'No command could handle "invalid".'
        end
      end
    end
  end
end
