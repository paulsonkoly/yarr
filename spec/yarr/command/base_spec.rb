require 'spec_helper'
require 'yarr/command/base'

RSpec.describe Yarr::Command::Base do
  let(:ast) { 'invalid' }

  describe '#handle' do
    let(:command) { described_class.new(ast: ast) }

    it 'handles everything' do
      expect(command.handle)
        .to eq "Yarr::Command::Base doesn't know how to handle invalid"
    end
  end

  describe '.match?' do
    it 'rejects everything' do
      expect(described_class.match?(ast)).to be false
    end
  end
end
