require 'spec_helper'

require 'yarr'

RSpec.describe Yarr::Bot do
  it 'does ri instance_method' do
    expect(subject.reply_to('ri instance_method')).to eq 'https://ruby-doc.org/core-2.5.1/Module.html#method-i-instance_method'
  end

  it 'does ri File.size' do
    expect(subject.reply_to('ri File.size')).to eq 'https://ruby-doc.org/core-2.5.1/File.html#method-c-size'
  end

  it 'does ri File' do
    expect(subject.reply_to('ri File')).to eq 'https://ruby-doc.org/core-2.5.1/File.html'
  end

  it 'does list F%le' do
    expect(subject.reply_to('list F%le')).to eq 'File'
  end

  it 'does list F%le.si%' do
    expect(subject.reply_to('list F%le.si%')).to eq 'File.size, File.size?'
  end
end
