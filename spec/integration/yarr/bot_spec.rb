require 'spec_helper'
require 'yarr/bot'

RSpec.describe Yarr::Bot do
  let(:bot) { subject }

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
    expect(bot.reply_to('xxx aaa')).to start_with('parser error')
  end

  it 'reports error for targets it can\'t parse' do
    expect(bot.reply_to('xxx @@')).to start_with('parser error')
  end

  it 'points to the right place of the error' do
    expect(bot.reply_to('ri @@@')).to match('around `r\'')
  end

  it 'does fact pizza' do
    expect(bot.reply_to('fact pizza')).to eq "here's your pizza: 🍕"
  end
end
