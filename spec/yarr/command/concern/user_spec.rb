require 'yarr/command/concern/responder'
require 'cinch'

RSpec.describe Yarr::Command::Concern::User do
  include described_class

  describe '#op?' do
    context 'with | in the nick' do
      let(:user) do
        instance_double(Cinch::User, nick: 'xx||yy', host_unsynced: 'blah')
      end

      it 'defends against regexp injection' do
        expect(op?(user)).to be_falsey
      end
    end

    context 'with _ in the nick and not in the host mask' do
      let(:user) do
        instance_double(Cinch::User,
                        nick: '_xx',
                        host_unsynced: "#{Yarr.config.ops_host_mask}xx")
      end

      it 'is truthy' do
        expect(op?(user)).to be_truthy
      end
    end

    context 'with nil host' do
      let(:user) { instance_double(Cinch::User, nick: 'x', host_unsynced: nil) }

      it 'is falsey' do
        expect(op?(user)).to be_falsey
      end
    end
  end
end
