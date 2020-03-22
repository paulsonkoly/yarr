require 'spec_helper'
require 'yarr/query/fact'

RSpec.describe Yarr::Command::RenameFact do
  subject { described_class.new(ast: ast) }

  let(:attributes) { attributes_for(:fact) }
  let(:fact) { build(:fact, **attributes) }
  let(:ast) do
    Yarr::AST.new(command: 'fact',
                  sub_command: 'rename',
                  old_name: old_name,
                  new_name: new_name)
  end
  let(:old_name) { fact.name }
  let(:new_name) { 'name different from previous name' }
  let(:new_attributes) { attributes.merge(name: new_name) }

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

      it "responds with the I don't know anything about .. message" do
        expect(handling)
          .to eq "I don't know anything about #{old_name}."
      end
    end

    context 'when there was a factoid with that name' do
      before { fact.save }

      it 'removes the factoid from the old name' do
        expect { handling }.to change { Yarr::Query::Fact[name: old_name] }
          .from(an_object_having_attributes(attributes))
          .to(nil)
      end

      it 'adds the factoid under the new name' do
        expect { handling }.to change { Yarr::Query::Fact[name: new_name] }
          .from(nil)
          .to(an_object_having_attributes(new_attributes))
      end

      it "doesn't alter the factoid count" do
        expect { handling }.not_to change(Yarr::Query::Fact, :count)
      end

      it 'responds with the I will remember .. message' do
        expect(handling)
          .to eq "I will remember that #{old_name} " \
                "is actually called #{new_name}."
      end
    end

    context 'when there was a factoid with the new name' do
      before do
        fact.save
        create(:fact, ** new_attributes)
      end

      it "doesn't remove the factoid from the old name" do
        expect { handling }
          .not_to(change { Yarr::Query::Fact[name: old_name] })
      end

      it "doesn't change the factoid under the new name" do
        expect { handling }
          .not_to(change { Yarr::Query::Fact[name: new_name] })
      end

      it 'responds with the name collision .. message' do
        expect(handling)
          .to eq "Name collision as #{new_name} is already taken."
      end
    end
  end
end
