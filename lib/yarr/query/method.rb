module Yarr
  module Query
    # Methods are stored in the database. Method classes provide an access
    # interface.
    #
    # @example
    #
    #    a = Method::Strict.query('size')
    #    a.count # => 17
    #    a.first.name # => 'size'
    #    a.first.flavour # => 'instance'
    module Method
      # Database object for methods.
      # For usage examples see {Method}.
      class Base
        def initialize(name, url, flavour, klass)
          @name = name
          @url = url
          @flavour = flavour
          @klass = klass
        end
        protected :initialize

        # @!attribute [r] name
        #   @return [String] the method name
        # @!attribute [r] url
        #   @return [String] the method url
        # @!attribute [r] flavour
        #   @return [String] either 'instance' or 'class'
        # @!attribute [r] klass
        #   @return [Integer] the class_id of the asscociated class
        attr_reader :name, :url, :flavour, :klass

        # @return [String] the name of the method
        def to_s
          @name
        end
      end

      # Queries methods by name using strict lookup rules.
      # For usage examples see {Method}.
      class Strict < Base
        # Queries methods by name using strict lookup rules. {Result} is an
        # Enumerable of {Base} objects.
        # @param name [String] the name of the method
        def self.query(name:)
          dataset = DB[:methods].where(name: name)
          Result.new(dataset, -> row {
            new(row[:name], row[:url], row[:flavour], row[:class_id])
          })
        end
      end

      # Queries methods using SQL like lookup.
      # For usage examples see {Method}.
      class Like < Base
        # Queries methods using SQL like lookup. {Result} is an Enumerable of
        # {KlassAndMethod} objects.
        # @param name [String] the name of the method
        def self.query(name:)
          dataset = DB[:classes]
            .join(:methods, class_id: :id)
            .select(Sequel[:methods][:name].as(:method_name),
          Sequel[:methods][:url].as(:method_url),
          Sequel[:methods][:flavour].as(:method_flavour),
          Sequel[:classes][:name].as(:class_name),
          Sequel[:classes][:url].as(:class_url))
            .where(Sequel[:methods][:name].like(name))

          Result.new(dataset, -> row {
            klass = Klass.new(row[:class_name], row[:class_url])
            method = new(row[:method_name],
                         row[:method_url],
                         row[:method_flavour],
                         row[:class_id])
            KlassAndMethod.new(klass, method)
          })
        end
      end
    end
  end
end
