require 'spec_helper'
require 'yarr/bot'

RSpec.describe Yarr::Bot do
  subject { bot.reply_to('request', user_requesting) }
  let(:input_parser) { instance_double(Yarr::InputParser) }
  let(:ast) { instance_double(Yarr::AST) }
  let(:handler) { instance_double(Yarr::Command::Base) }
  let(:bot) { described_class.new(irc, input_parser) }
  let(:irc) { double('Irc', user_list: user_list) }
  let(:user_list) { instance_double(Yarr::NoIRC::UserList) }
  let(:stuff) { nil }
  let(:user_requesting) do
    double('User requesting', nick: 'user_requesting', online?: true)
  end
  let(:user_targeted) do
    double('User targeted', nick: 'user_targeted', online?: true)
  end
  let(:raw_response) { 'x' }
  let(:response) { bot.reply_to('request', user) }

  before do
    allow(input_parser).to receive(:parse).and_return(ast)
    allow(Yarr::Command).to receive(:for_ast)
      .with(ast, irc, user_requesting).and_return(handler)
    allow(ast).to receive(:[]).with(:stuff).and_return(stuff)
    allow(handler).to receive(:handle).and_return(raw_response)
    allow(user_list).to receive(:find) do |nick|
      [user_requesting, user_targeted].find { |user| nick == user.nick }
    end
  end

  describe '#reply_to' do
    it { is_expected.to eq 'x' }
  end

  context 'when stuff contains a user targeted' do
    let(:stuff) { 'user_targeted' }

    it 'prefixes the response with the user targeted' do
      expect(subject).to eq 'user_targeted: x'
    end
  end

  context 'when stuff contains garbage' do
    let(:stuff) { 'garbage' }

    it 'ignores it' do
      expect(subject).to eq 'x'
    end
  end

  context 'when command raises an error' do
    before do
      allow(handler).to receive(:handle).and_raise(Yarr::Error, 'whoopsie')
    end

    it 'reports the error and targets the requesting user' do
      expect(subject).to eq 'user_requesting: whoopsie'
    end
  end

  context 'when command result is too long' do
    let(:raw_response) { 'x' * 1_000 }

    it 'truncates' do
      expect(subject.length).to be <= Yarr::Message::Truncator::MAX_LENGTH
    end
  end

  context 'when error message is too long' do
    before do
      allow(handler).to receive(:handle).and_raise(Yarr::Error, 'x' * 1_000)
    end

    it 'truncates' do
      expect(subject.length).to be <= Yarr::Message::Truncator::MAX_LENGTH
    end
  end

  context 'when targeted user nick is too long' do
    let(:stuff) { 'x' * 1_000 }
    let(:user_targeted) do
      double('User targeted', nick: 'x' * 1_000, online?: true)
    end

    it 'truncates' do
      expect(subject.length).to be <= Yarr::Message::Truncator::MAX_LENGTH
    end
  end

  context 'when requesting user nick is too long' do
    before do
      allow(handler).to receive(:handle).and_raise(Yarr::Error)
    end
    let(:user_requesting) do
      double('User requesting', nick: 'x' * 1_000, online?: true)
    end

    it 'truncates' do
      expect(subject.length).to be <= Yarr::Message::Truncator::MAX_LENGTH
    end
  end
end
