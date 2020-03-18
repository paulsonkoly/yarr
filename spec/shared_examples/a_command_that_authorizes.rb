RSpec.shared_examples 'a command that authorizes' do |role|
  let(:command) { subject }

  let(:user) { Yarr::NoIRC::User.new }
  before do
    allow(Yarr::NoIRC).to receive(:irc).and_return(:online)
    allow(command).to receive(:user).and_return(user)
  end

  context "when the user is an #{role}" do
    before do
      allow(command).to receive("#{role}?").with(user).and_return true
    end

    it "doesn't raise authorization errors" do
      expect { subject.handle }.not_to raise_error
    end
  end

  context "when the user is not an #{role}" do
    before do
      allow(command).to receive("#{role}?").with(user).and_return false
    end

    it 'raises authorization error' do
      expect { subject.handle }
        .to raise_error Yarr::Command::Concern::Authorize::AuthorizationError
    end
  end
end
