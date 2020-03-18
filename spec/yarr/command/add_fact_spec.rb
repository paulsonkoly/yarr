require 'spec_helper'
require 'yarr/query/fact'

RSpec.describe Yarr::Command::AddFact do
  subject { described_class.new(ast: ast) }

  let(:fact) { build(:fact) }
  let(:ast) do
    Yarr::AST.new(command: 'fact',
                  sub_command: 'add',
                  name: name,
                  content: content)
  end
  let(:name) { fact.name }
  let(:content) { fact.content }

  it_behaves_like 'a command that authorizes', :op

  describe '#match?' do
    it 'matches the command fact sub_command add' do
      expect(described_class).to be_able_to_handle ast
    end

    context 'with command being ?' do
      let(:command) { '?' }

      it 'matches the command fact sub_command add' do
        expect(described_class).to be_able_to_handle ast
      end
    end
  end

  describe '#handle' do
    subject(:handling) { described_class.new(ast: ast).handle }

    context 'when there was no factoid with that name' do
      it 'saves the new fact in the database' do
        expect { handling }.to change { Yarr::Query::Fact[name: name] }
          .from(nil)
          .to(an_object_having_attributes(name: name,
                                          content: content,
                                          count: 0))
      end

      it 'responds with the I will remember .. message' do
        expect(handling)
          .to eq "I will remember that pizza is here's your pizza: 🍕"
      end
    end

    context 'when there was already a factoid with that name' do
      before { fact.save }

      it "doesn't create a new factoid" do
        expect { handling }.not_to change(Yarr::Query::Fact, :count)
      end

      it "doesn't change the existing factoid" do
        expect { handling }.not_to(change { Yarr::Query::Fact[:name] })
      end

      it 'responds with the I  already know .. message' do
        expect(handling)
          .to eq "I already know that pizza is here's your pizza: 🍕"
      end
    end
  end
end
