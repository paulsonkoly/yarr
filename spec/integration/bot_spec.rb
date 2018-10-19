require 'spec_helper'
require 'yarr/bot'

RSpec.describe Yarr::Bot do
  it 'does ri size' do
    expect(subject.reply_to('ri size')).to eq 'https://ruby-doc.org/core-2.5.1/Array.html#method-i-size'
  end

  it 'does ri Array.size' do
    expect(subject.reply_to('ri size')).to eq 'https://ruby-doc.org/core-2.5.1/Array.html#method-i-size'
  end

  it 'does ri Array' do
    expect(subject.reply_to('ri Array')).to eq 'https://ruby-doc.org/core-2.5.1/Array.html'
  end

  it 'does list Ar%y' do
    expect(subject.reply_to('list Ar%y')).to eq 'Array (test)'
  end

  it 'does list Ar%y#si%' do
    expect(subject.reply_to('list Ar%y#si%')).to eq 'Array#size'
  end

  it 'reports error for commands it doesn\'t understand' do
    expect(subject.reply_to('xxx aaa')).to match /did not understand command xxx/
  end

  it 'reports error for targets it can\'t parse' do
    expect(subject.reply_to('xxx @@')).to match /did not understand command the command target/
  end
end
