require 'spec_helper'

module Yarr
  module Command
    RSpec.describe Fact do
      let(:ast) { Yarr::AST.new(command: command, name: name) }
      let(:command) { 'fact' }
      let(:name) { 'pizza' }

      describe '#match?' do
        it 'matches the command fact' do
          expect(described_class).to be_able_to_handle ast
        end

        context 'with command being ?' do
          let(:command) { '?' }

          it 'matches' do
            expect(described_class).to be_able_to_handle ast
          end
        end
      end

      describe '#handle' do
        subject { described_class.new(ast: ast).handle }

        it { is_expected.to eq "here's your pizza: 🍕" }

        context 'when no factoid is found' do
          let(:name) { 'non-existent' }

          it { is_expected.to eq "I don't know anything about non-existent." }
        end
      end
    end
  end
end
