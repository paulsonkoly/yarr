require 'tmpdir'
require 'spec_helper'
require 'helpers/env_variable_helper'
require 'yarr/configuration'

module Yarr
  RSpec.describe Configuration do
    context 'with YARR_TEST set to 1' do
      environment_variable('YARR_TEST') { ENV['YARR_TEST'] = '1' }

      it { is_expected.to be_test }
    end

    context 'with TEST unset' do
      environment_variable('YARR_TEST') { ENV.delete('YARR_TEST') }

      it { is_expected.not_to be_test }
    end

    describe 'file based configuration' do
      let(:config) do
        dir = tmpdir
        app_config = AppConfiguration.new do
          config_file_name 'yarr.yml'
          base_local_path dir
          base_global_path dir
          prefix 'yarr'
        end
        described_class.new(app_config)
      end

      let(:username) { Faker::Internet.username }
      let(:password) { Faker::Internet.password }

      let(:tmpdir) { Dir.mktmpdir }
      let(:tmpfile) { File.join(tmpdir, 'yarr.yml') }

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
          expect(config.username).to eq username
        end
      end

      describe '#password' do
        it 'matches the password from the configuration file' do
          expect(config.password).to eq password
        end
      end
    end
  end

  RSpec.describe 'Yarr.configuration' do
    subject { Yarr.config }

    it { is_expected.to be_a Yarr::Configuration }
  end
end
