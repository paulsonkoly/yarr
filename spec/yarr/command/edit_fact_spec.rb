require 'spec_helper'
require 'yarr/query/fact'

RSpec.describe Yarr::Command::EditFact do
  subject { described_class.new(ast: ast) }

  let(:attributes) { attributes_for(:fact) }
  let(:fact) { build(:fact, **attributes) }
  let(:ast) do
    Yarr::AST.new(command: 'fact',
                  sub_command: 'edit',
                  name: name,
                  content: new_content)
  end
  let(:name) { fact.name }
  let(:content) { fact.content }
  let(:new_content) { 'content different from previous content' }
  let(:new_attributes) { attributes.merge(content: new_content) }

  it_behaves_like 'a command that authorizes', :op

  describe '#match?' do
    it 'matches the command fact sub_command edit' do
      expect(described_class).to be_able_to_handle ast
    end
  end

  describe '#handle' do
    subject(:handling) { described_class.new(ast: ast).handle }

    context 'when there was no factoid with that name' do
      it "doesn't create a new factoid" do
        expect { handling }.not_to change(Yarr::Query::Fact, :count)
      end

      it 'responds with the did you mean to teach me .. message' do
        expect(handling)
          .to eq "I'm sorry, did you mean to teach me about #{fact.name}? " \
        'Please use `fact add` for that.'
      end
    end

    context 'when there was a factoid with that name' do
      before { fact.save }

      it 'saves the new content of the factoid' do
        expect { handling }.to change { Yarr::Query::Fact[name: name] }
          .from(an_object_having_attributes(attributes))
          .to(an_object_having_attributes(new_attributes))
      end

      it 'responds with the I stand corrected .. message' do
        expect(handling)
          .to eq "I stand corrected that #{fact.name} is #{new_content}"
      end
    end
  end
end
