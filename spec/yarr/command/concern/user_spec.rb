require 'yarr/command/concern/responder'

RSpec.describe Yarr::Command::Concern::User do
  include described_class

  describe '#op?' do
    context 'with | in the nick' do
      let(:user) { double('user', nick: 'xx||yy', host: 'blah') }

      it 'defends against regexp injection' do
        expect(op?(user)).to be_falsey
      end
    end

    context 'with nil host' do
      let(:user) { double('user', nick: 'x', host: nil) }

      it 'is falsey' do
        expect(op?(user)).to be_falsey
      end
    end
  end
end
