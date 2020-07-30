# frozen_string_literal: true

require 'spec_helper'
require 'yarr/query/fact'

RSpec.describe Yarr::Command::RemoveFact do
  subject { described_class.new(ast: ast) }

  let(:fact) { build(:fact) }
  let(:ast) do
    Yarr::AST.new(command: 'fact',
                  sub_command: 'remove',
                  name: name)
  end
  let(:name) { fact.name }

  it_behaves_like 'a command that authorizes', :op

  describe '#match?' do
    it 'matches the command fact sub_command remove' do
      expect(described_class).to be_able_to_handle ast
    end
  end

  describe '#handle' do
    subject(:handling) { described_class.new(ast: ast).handle }

    context 'when there was already a factoid with that name' do
      before { fact.save }

      it 'removes the factoid from the database' do
        expect { handling }.to change { Yarr::Query::Fact[name: name] }
          .from(an_object_existing)
          .to(nil)
      end

      it 'reduces the known factoid count' do
        expect { handling }.to change(Yarr::Query::Fact, :count).by(-1)
      end

      it 'responds with the I forgot what .. message' do
        expect(handling).to eq "I forgot what #{fact.name} is."
      end
    end

    context "when there wasn't a factoid with that name" do
      it "doesn't delete the factoid" do
        expect { handling }.not_to change(Yarr::Query::Fact, :count)
      end

      it 'responds with the I never knew .. message' do
        expect(handling)
          .to eq "I never knew what #{fact.name} is."
      end
    end
  end
end
