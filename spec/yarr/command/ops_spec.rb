require 'spec_helper'
require 'yarr/command/ops'

RSpec.describe Yarr::Command::Ops do
  let(:ast) { Yarr::AST.new(command: 'ops') }
  let(:irc) { double('irc', user_list: [normal_user, *operators]) }
  let(:normal_user) { build(:user) }
  let(:operators) { build_list(:operator, 2) }
  let(:command) { described_class.new(ast: ast, irc: irc) }

  describe '#handle' do
    it 'returns a comma separated list of the operators' do
      op_nicks = operators.map(&:nick).sort.join(', ')
      expect(command.handle).to eq op_nicks
    end
  end
end
