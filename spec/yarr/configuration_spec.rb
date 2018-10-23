require 'spec_helper'
require 'yarr/configuration'

module Yarr
  RSpec.describe Configuration do
    context 'with YARR_TEST set to 1' do
      it { is_expected.to be_test }
      it { is_expected.not_to be_production }
    end

    context 'with TEST unset' do
      before { ENV.delete('YARR_TEST') }
      # we need to restore this for other tests
      after { ENV['YARR_TEST'] = '1' }

      it { is_expected.not_to be_test }
      it { is_expected.to be_production }
    end

    describe 'file based configuration' do
      let(:username) { Faker::Internet.username }
      let(:password) { Faker::Internet.password }

      let(:tmpdir) { Dir.mktmpdir }
      let(:tmpfile) { File.join(tmpdir, 'yarr.yml') }

      subject do
        dir = tmpdir
        app_config = AppConfiguration.new do
          config_file_name 'yarr.yml'
          base_local_path dir
          base_global_path dir
          prefix 'yarr'
        end
        described_class.new(app_config)
      end

      before do
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
  end

  RSpec.describe 'Yarr.configuration' do
    subject { Yarr.config }

    it { is_expected.to be_a Yarr::Configuration }
  end
end
