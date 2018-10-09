require_relative '../spec_helper'

require 'yarr/config_file'

module Yarr
  RSpec.describe ConfigFile do
    let(:xdg) { double('xdg') }
    subject { described_class.new(xdg) }

    let(:username) { Faker::Internet.username }
    let(:password) { Faker::Internet.password }

    let(:tmpdir) { Dir.mktmpdir }
    let(:tmpfile) { File.join(tmpdir, 'yarr.yml') }

    before do
      allow(xdg).to receive(:with_subdirectory).and_return(tmpdir)

      File.open(tmpfile, 'w') do |f|
        f.write("username: '#{username}'\n")
        f.write("password: '#{password}'\n")
      end
    end

    after do
      FileUtils.rm(tmpfile)
    end

    describe '.username' do
      it 'matches the username from the configuration file' do
        expect(subject.username).to eq username
      end
    end

    describe '.password' do
      it 'matches the password from the configuration file' do
        expect(subject.password).to eq password
      end
    end
  end
end
