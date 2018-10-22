module Yarr
  # Environment setup
  #
  # Export environment variables to change the set up. Supported variables:
  #
  #   - YARR_TEST => use test database
  #   - YARR_DEVELOPMENT => output verbose debug info
  module Environment
    # :reek:UtilityFunction

    # Yarr running in test environment
    def test?
      ENV['YARR_TEST'] == '1'
    end

    # :reek:UtilityFunction

    # Yarr running in development environment
    def development?
      ENV['YARR_DEVELOPMENT'] == '1'
    end

    # Yarr running in production environment
    def production?
      ! test? && ! development?
    end

    # The root directory of the project
    PROJECT_ROOT = File.join(File.dirname(__FILE__), '..', '..').freeze

    extend self
  end
end
