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
  #   - YARR_DEVELOPMENT => output verbose debug info
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
    %i[test development username password nick channels evaluator].each do |sym|
      define_method(sym) { @config.public_send(sym) }
    end

    # :reek:UtilityFunction

    # @return [Bool] Yarr running in test environment
    def test?
      test == '1'
    end

    # :reek:UtilityFunction

    # @return [Bool] Yarr running in development environment
    def development?
      development == '1'
    end
  end

  class << self
    # @return [Configuration] the project setup
    def configuration
      Configuration.new
    end
    alias_method :config, :configuration
  end
end
