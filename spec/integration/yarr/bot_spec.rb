require 'spec_helper'
require 'yarr/bot'
require 'yarr/query'

RSpec.describe Yarr::Bot do
  let(:bot) { subject }

  before do
    array = create :klass, name: 'Array'
    create :method, flavour: 'instance', name: 'size', klass: array
    origin = create :origin, name: 'abbrev'
    create :klass, name: 'Array', origin: origin
    create :fact, name: 'pizza', content: "here's your pizza: 🍕"
  end

  it 'does ri size' do
    expect(bot.reply_to('ri size')).to match %r{https://ruby-doc.org/.*/Array.html#method-i-size}
  end

  it 'does ri Array#size' do
    expect(bot.reply_to('ri Array#size')).to match %r{https://ruby-doc.org/.*/Array.html#method-i-size}
  end

  it 'does ri Array' do
    expect(bot.reply_to('ri Array')).to match %r{https://ruby-doc.org/.*/Array.html}
  end

  it 'does list Ar%y' do
    expect(bot.reply_to('list Ar%y')).to eq 'Array, Array (abbrev)'
  end

  it 'does list Ar%y#si%' do
    expect(bot.reply_to('list Ar%y#si%')).to eq 'Array#size'
  end

  it 'reports error for commands it doesn\'t understand' do
    expect(bot.reply_to('xxx aaa')).to include('parser error')
  end

  it 'reports error for targets it can\'t parse' do
    expect(bot.reply_to('xxx @@')).to include('parser error')
  end

  it 'points to the right place of the error' do
    expect(bot.reply_to('ri @@@')).to match('around `r\'')
  end

  it 'does fact pizza' do
    expect(bot.reply_to('fact pizza')).to eq "here's your pizza: 🍕"
  end

  it 'can add a new fact' do
    expect { bot.reply_to('fact add x y') }
      .to change(Yarr::Query::Fact, :count).by(1)
  end

  context 'when the bot is connected to irc' do
    let(:irc_user) { double('Irc user', online?: true, nick: 'phaul') }

    it 'includes the initiating user if the command raises' do
      expect(bot.reply_to('xxx @@', irc_user)).to start_with('phaul')
    end
  end
end
