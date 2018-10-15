require 'sequel'
require 'forwardable'

module Yarr
  # Handles connecting to sequel.
  class Database
    extend Forwardable

    def initialize(connector = :sqlite)
      # TODO project root path
      db_path = File.dirname(__FILE__)
      @db_dir = File.join(db_path, '..', '..', 'db')
      @db_path = File.join(@db_dir, ENV['TEST'] ? 'test' : 'database')

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
