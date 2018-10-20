require 'spec_helper'
require 'yarr/config_file'

module Yarr
  RSpec.describe ConfigFile do
    context 'with a config file stubbed' do
      let(:username) { Faker::Internet.username }
      let(:password) { Faker::Internet.password }

      let(:tmpdir) { Dir.mktmpdir }
      let(:tmpfile) { File.join(tmpdir, 'yarr.yml') }

      before do
        allow(subject).to receive(:config_file).and_return(tmpfile)

        File.open(tmpfile, 'w') do |f|
          f.write("username: '#{username}'\n")
          f.write("password: '#{password}'\n")
        end
      end

      after do
        FileUtils.rm(tmpfile)
      end

      describe '#username' do
        it 'matches the username from the configuration file' do
          expect(subject.username).to eq username
        end
      end

      describe '#password' do
        it 'matches the password from the configuration file' do
          expect(subject.password).to eq password
        end
      end
    end

    describe '#config_file' do
      it 'ends with yarr.yml' do
        expect(subject.send :config_file).to end_with 'yarr.yml'
      end
    end
  end
end
