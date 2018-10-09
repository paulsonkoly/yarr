module Yarr
  # A YAML configuration file loader for yarr.
  class ConfigFile
    # A Yarr configuration file at a predefined location.
    # @param xdg XDG provider.
    def initialize(xdg = XDG['CONFIG_HOME'])
      @xdg = xdg.with_subdirectory('yarr')
    end

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
      File.join(@xdg.to_s, 'yarr.yml')
    end

    def config_data
      @config_data ||= File.open(config_file, 'r') do |io|
        YAML.load(io.read)
      end
    end
  end
end
