require 'spec_helper'
require 'yarr/command/ops'

RSpec.describe Yarr::Command::Ops do
  let(:ast) { Yarr::AST.new(command: 'ops') }
  let(:irc) { double('irc', user_list: [normal_user, operator1, operator2]) }
  let(:normal_user) do
    double('normal_user', host_unsynced: 'some host', nick: 'normal')
  end
  let(:operator1) do
    double('operator',
           host_unsynced: "#{Yarr.config.ops_host_mask}op1",
           nick: 'op1')
  end
  let(:operator2) do
    double('operator',
           host_unsynced: "#{Yarr.config.ops_host_mask}op2",
           nick: 'op2')
  end
  let(:command) { described_class.new(ast: ast, irc: irc) }

  describe '#handle' do
    it 'returns a comma spearated list of the operators' do
      expect(command.handle).to eq 'op1, op2'
    end
  end
end
