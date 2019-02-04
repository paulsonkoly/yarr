require 'sequel'
require 'forwardable'
require 'yarr/configuration'

module Yarr
  # Handles connecting to sequel.
  class Database
    extend Forwardable

    # @param connector [symbol] the database connector
    def initialize(connector = :sqlite)
      @db_dir = File.join(PROJECT_ROOT, 'db')
      @db_path = File.join(@db_dir, Yarr.config.test? ? 'test' : 'database')

      @db = Sequel.public_send(connector, @db_path)

      (@db.methods - methods).each do |method|
        self.class.class_eval do
          def_delegator :@db, method
        end
      end
    end

    attr_reader :db_path, :db_dir
  end

  # The application's database connection. A {Database} instance.
  DB = Database.new
end
