module Yarr
  module Query
    # Classes are stored in the database. Klasses provide an access interface.
    #
    # @example
    #
    #    a = Klass::Strict.query('Array')
    #    a.count # => 1
    #    a.first.name # => 'Array'
    #    a.first.url # => 'array.html'
    module Klass
      # Database object for classes.
      # For usage examples see {Klass}.
      class Base
        def initialize(name, url)
          @name = name
          @url = url
        end
        protected :initialize

        # @!attribute [r] name
        #   @return [String] the class name
        # @!attribute [r] url
        #   @return [String] the class url
        attr_reader :name, :url

        # @return [String] the name of the class
        def to_s
          @name
        end
      end

      # Queries klasses by name using strict lookup rules.
      # For usage examples see {Klass}.
      class Strict < Base
        def self.query(name:)
          dataset = DB[:classes].where({ name: name })
          Result.new(dataset, -> row {
            new(row[:name], row[:url])
          })
        end
      end

      # Queries klasses using SQL like lookup.
      # For usage examples see {Klass}.
      class Like < Base
        def self.query(name:)
          dataset = DB[:classes].where(Sequel[:name].like(name))
          Result.new(dataset, -> row {
            new(row[:name], row[:url])
          })
        end
      end
    end
  end
end
