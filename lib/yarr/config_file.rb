require 'yaml'
require 'yarr/environment'

module Yarr
  # A YAML configuration file loader for yarr.
  class ConfigFile
    # Username loaded from configuration
    def username
      config_data['username']
    end

    # Password loaded from configuration
    def password
      config_data['password']
    end

    private

    def config_file
      File.join(Environment::PROJECT_ROOT, 'config', 'yarr.yml')
    end

    def config_data
      @config_data ||= File.open(config_file, 'r') do |io|
        YAML.load(io.read)
      end
    end
  end
end
