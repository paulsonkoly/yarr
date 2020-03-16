require 'yarr/command/concern/responder'
require 'cinch'

RSpec.describe Yarr::Command::Concern::User do
  include described_class

  describe '#op?' do
    context 'with | in the nick' do
      let(:user) { build(:user, nick: 'xx||yy') }

      it 'defends against regexp injection' do
        expect(op?(user)).to be_falsey
      end
    end

    context 'with _ in the nick and not in the host mask' do
      let(:user) { build(:operator, nick: '_xx') }

      it 'is truthy' do
        expect(op?(user)).to be_truthy
      end
    end

    context 'with nil host' do
      let(:user) { build(:operator, host_unsynced: nil) }

      it 'is falsey' do
        expect(op?(user)).to be_falsey
      end
    end

    context 'when user is not online' do
      let(:user) { build(:operator, host_unsynced: nil) }

      it 'is falsey' do
        expect(op?(user)).to be_falsey
      end
    end
  end
end
