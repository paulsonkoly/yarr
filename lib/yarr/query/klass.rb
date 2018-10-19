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
        def initialize(name, url, origin)
          @name = name
          @url = url
          @origin = origin
        end
        protected :initialize

        # @!attribute [r] name
        #   @return [String] the class name
        # @!attribute [r] origin
        #   @return [String] the gem in which this was defined. Some rupy
        #                    classes span across multiple gems, as far as we
        #                    are concerned those are distinct classes with the
        #                    same name.
        attr_reader :name, :url, :origin

        # @return [String] the name of the class
        def to_s
          @name + (core? ? '' : " (#{origin})")
        end

        # @return [String] the ri url for the class
        def url
          core? ? "core-2.5.1/#@url" : "stdlib-2.5.1/libdoc/#@origin/rdoc/#@url"
        end

        private

        def core?
          @origin == 'core'
        end
      end

      # Queries klasses by name using strict lookup rules.
      # For usage examples see {Klass}.
      class Strict < Base
        # Queries classes by name using strict lookup rules.
        # @param name [String] the class name
        # @return [Result]
        def self.query(name:)
          dataset = DB[:origins]
            .join(:classes, origin_id: :id)
            .select(Sequel[:classes][:name].as(:name),
                    Sequel[:classes][:url].as(:url),
                    Sequel[:origins][:name].as(:origin))
            .where(Sequel[:classes][:name] => name)

          Result.new(dataset, -> row {
            new(row[:name], row[:url], row[:origin])
          })
        end
      end

      # Queries klasses using SQL like lookup.
      # For usage examples see {Klass}.
      class Like < Base
        # Queries classes by name using SQL like query
        # @param name [String] the class name, % wildcard allowed
        # @return [Result]
        def self.query(name:)
          dataset = DB[:origins]
            .join(:classes, origin_id: :id)
            .select(Sequel[:classes][:name].as(:name),
                    Sequel[:classes][:url].as(:url),
                    Sequel[:origins][:name].as(:origin))
            .where(Sequel[:classes][:name].like(name))

          Result.new(dataset, -> row {
            new(row[:name], row[:url], row[:origin])
          })
        end
      end
    end
  end
end
