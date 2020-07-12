require 'sequel'
require 'forwardable'
require 'yarr/configuration'

module Yarr
  # Handles connecting to sequel.
  class Database
    extend Forwardable

    # Connection to the database
    # @param connector [symbol] the database connector
    def initialize(connector = :sqlite)
      @db_dir = File.join(PROJECT_ROOT, 'db')
      @db_path = File.join(@db_dir, Yarr::CONFIG.test? ? 'test' : 'database')

      @db = Sequel.public_send(connector, @db_path)

      (@db.methods - methods).each do |method|
        self.class.class_eval do
          def_delegator :@db, method
        end
      end
    end

    # @!attribute [r] db_path
    #   @return [String] path to the database file
    # @!attribute [r] db_dir
    #   @return [String] directory containing the database file
    attr_reader :db_path, :db_dir
  end

  # The application's database connection. A {Database} instance.
  DB = Database.new
end
