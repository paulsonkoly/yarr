require 'yarr/query/klass'
require 'yarr/query/klass_and_method'

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
        def initialize(name, url, flavour, klass, origin)
          @name = name
          @url = url
          @flavour = flavour
          @klass = klass
          @origin = origin
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
        # @!attribute [r] origin
        #   @return [String] gem name/'core'
        attr_reader :name, :url, :flavour, :klass, :origin

        # @return [String] the name of the method
        def to_s
          @name
        end

        private

        def self.methods
          Sequel[:methods]
        end

        def self.klasses
          Sequel[:classes]
        end
      end

      # Queries methods by name using strict lookup rules.
      # For usage examples see {Method}.
      class Strict < Base
        # Queries methods by name using strict lookup rules.
        # @param name [String] the method name
        # @return [Result]
        def self.query(name:)
          dataset = DB[:origins]
            .join(:methods, origin_id: :id)
            .select(Sequel[:origins][:name].as(:origin_name))
            .where(name: name)
          Result.new(dataset, -> row {
            new(row[:name],
                row[:url],
                row[:flavour],
                row[:class_id],
                row[:origin_name])
          })
        end
      end

      # Queries methods using SQL like lookup.
      # For usage examples see {Method}.
      class Like < Base
        # Queries methods using SQL like lookup.
        # @param name [String] the method name, % wildcards allowed
        # @return [Result]
        def self.query(name:)
          dataset = DB[:origins]
            .join(:classes, origin_id: :id)
            .join(:methods, class_id: :id)
            .select(methods[:name].as(:method_name),
                    methods[:url].as(:method_url),
                    methods[:flavour].as(:method_flavour),
                    klasses[:name].as(:class_name),
                    klasses[:url].as(:class_url),
                    Sequel[:origins][:name].as(:class_origin))
            .order(Sequel[:origins][:id])
            .where(Sequel[:methods][:name].like(name))

          Result.new(dataset, -> row {
            klass = Klass::Like.new(row[:class_name],
                                    row[:class_url],
                                    row[:class_origin])
            method = new(row[:method_name],
                         row[:method_url],
                         row[:method_flavour],
                         row[:class_id]
                         row[:origins])
            KlassAndMethod::Like.new(klass, method)
          })
        end
      end
    end
  end
end
