require 'spec_helper'
require 'yarr/bot'

RSpec.describe Yarr::Bot do
  it 'does ri size' do
    expect(subject.reply_to('ri size')).to match %r{https://ruby-doc.org/.*/Array.html#method-i-size}
  end

  it 'does ri Array.size' do
    expect(subject.reply_to('ri size')).to match %r{https://ruby-doc.org/.*/Array.html#method-i-size}
  end

  it 'does ri Array' do
    expect(subject.reply_to('ri Array')).to match %r{https://ruby-doc.org/.*/Array.html}
  end

  it 'does list Ar%y' do
    expect(subject.reply_to('list Ar%y')).to eq 'Array, Array (abbrev)'
  end

  it 'does list Ar%y#si%' do
    expect(subject.reply_to('list Ar%y#si%')).to eq 'Array#size'
  end

  it 'reports error for commands it doesn\'t understand' do
    expect(subject.reply_to('xxx aaa')).to start_with('did not understand that')
  end

  it 'reports error for targets it can\'t parse' do
    expect(subject.reply_to('xxx @@')).to start_with('did not understand that')
  end
end
