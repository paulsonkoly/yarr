# frozen_string_literal: true

require 'tmpdir'
require 'spec_helper'
require 'yarr/configuration'

RSpec.describe Yarr::Configuration do
  context 'with YARR_TEST set to 1' do
    include_context 'with environment variable', 'YARR_TEST' => 1

    it { is_expected.to be_test }
  end

  context 'with TEST unset' do
    include_context 'without environment variable', 'YARR_TEST'

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
        f.write <<~YML
          username: '#{username}'
          password: '#{password}'
          evaluator:
            :languages:
              :"27": "2.7.0"
            :modes:
              :default:
                :filter: {}
                :output: :truncate
                :format: |
                  %s
        YML
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

    describe '#evaluator' do
      subject { config.evaluator }

      it { is_expected.to be_a Hash }

      it 'can be called twice' do
        expect do
          config.evaluator
          config.evaluator
        end.not_to raise_error
      end
    end
  end
end

RSpec.describe 'Yarr::CONFIG' do
  subject { Yarr::CONFIG }

  it { is_expected.to be_a Yarr::Configuration }
end
