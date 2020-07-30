# frozen_string_literal: true

require 'app_configuration'

# The rubydoc lookup bot
module Yarr
  # The root directory of the project
  PROJECT_ROOT = File.join(File.dirname(__FILE__), '..', '..').freeze
  # The config file path
  CONFIG_PATH = File.join(PROJECT_ROOT, 'config').freeze

  # Export environment variables to change the set up. Supported variables:
  #
  #   - YARR_TEST => use test database
  #
  # configuration file can be in config/yarr.yml
  class Configuration
    # Default configuration settings
    DEFAULT_CONFIG = AppConfiguration.new do
      config_file_name 'yarr.yml'
      base_local_path CONFIG_PATH
      base_global_path CONFIG_PATH
      prefix 'yarr'
    end

    # Configuration including environment variables and configuration files
    # @param config [AppConfiguration::Config] DEFAULT_CONFIG is good in almost
    #               all cases
    def initialize(config = DEFAULT_CONFIG)
      @config = config
    end

    # @!method username
    #   @return [String] username for freenode

    # @!method password
    #   @return [String] password for freenode

    # @!method nick
    #   @return [String] bot's nick

    # @!method channels
    #   @return [[String]] array of channel names where the bot will be active

    # Forwardable doesn't play along nicely with AppConfiguration as these are
    # implemented via method_missing, no respond_to_missing, and forwardable
    # checks that.
    forwarded_methods = %i[test development username password nick channels
                           ops_host_mask]
    forwarded_methods.each do |sym|
      define_method(sym) { @config.public_send(sym) }
    end

    def evaluator
      evaluator = @config.evaluator
      return unless evaluator

      evaluator[:modes].transform_values!(&Evaluator::Mode.method(:new))
      evaluator
    end

    # @return [String] the ruby version that can be inserted in the ruby-doc
    # URLs.
    def ruby_version
      @config.public_send(__method__) || '2.6'
    end

    # @return [Bool] Yarr running in test environment
    def test?
      test == '1'
    end

    # @return [Bool] Yarr running in development environment
    def development?
      development == '1'
    end
  end

  CONFIG = Configuration.new.freeze
end
