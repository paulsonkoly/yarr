module Yarr
  # Environment setup
  #
  # Export environment variables to change the set up. Supported variables:
  #
  #   - TEST => use test database
  module Environment
    # :reek:UtilityFunction

    # Yarr running in test environment
    def test?
      ENV['TEST'] == '1'
    end

    # Yarr running in production environment
    def production?
      ! test?
    end

    # The root directory of the project
    PROJECT_ROOT = File.join(File.dirname(__FILE__), '..', '..').freeze

    extend self
  end
end
