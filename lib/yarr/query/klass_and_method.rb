module Yarr
  module Query
    # Methods belong to classes in the database. KlassAndMethod classes return
    # the join table entries.
    #
    # @example
    #
    #    a = KlassAndMethod::Like.query(method: 'siz%', klass: 'Arr%', flavour: 'instance')
    #    a.count # => 1
    #    a.method.name # => 'size'
    #    a.klass.name # => 'Array'
    module KlassAndMethod
      # Queries methods and klasses by method name, class name, method flavour.
      # For usage examples see {KlassAndMethod}.
      class Base
        def initialize(klass, method)
          @klass = klass
          @method = method
        end
        protected :initialize

        # @!attribute [r] klass
        #   @return [Klass] the class part of the database entry
        # @!attribute [r] method
        #   @return [Method] the method part of the database entry
        attr_reader :klass, :method

        # @return [String] returns the class name, method name concatenated by
        #                  '#' for instance methods, '.' for class methods
        def to_s
          delim = case method.flavour
                  when 'instance' then ?#
                  when 'class' then ?.
                  end
          "#{klass}#{delim}#{method}"
        end

        protected

        def self.query(method:, klass:, flavour:)
          dataset = DB[:classes]
            .join(:methods, class_id: :id)
            .select(methods[:name].as(:method_name),
                    methods[:url].as(:method_url),
                    methods[:flavour].as(:method_flavour),
                    klasses[:name].as(:class_name),
                    klasses[:url].as(:class_url))
            .where(constraint(method, klass, flavour))

          Result.new(dataset, -> row {
            new(Klass::Base.new(row[:class_name], row[:class_url]),
                Method::Base.new(row[:method_name], row[:method_url],
                                 row[:method_flavour], row[:class_id]))
          })
        end

        def self.methods
          Sequel[:methods]
        end

        def self.klasses
          Sequel[:classes]
        end
      end

      # Queries methods and klasses by method name, class name, method flavour
      # using strict lookup rules. For usage examples see {KlassAndMethod}.
      class Strict < Base
        # Queries methods using strict lookup rules.
        # @param method [String] method name
        # @param klass [String] class name
        # @param flavour [String] one of 'instance' or 'class'
        # @return [Result]
        def self.query(method:, klass:, flavour:)
          super
        end

        private

        def self.constraint(method, klass, flavour)
          { methods[:name] => method,
            klasses[:name] => klass,
            methods[:flavour] => flavour }
        end
      end

      # Queries methods and klasses by method name, class name, method flavour
      # using SQL like query. For usage examples see {KlassAndMethod}.
      class Like < Base
        # Queries methods using SQL like query.
        # @param method [String] method name, % wildcard allowed
        # @param klass [String] class name, % wildcard allowed
        # @param flavour [String] one of 'instance' or 'class'
        # @return [Result]
        def self.query(method:, klass:, flavour:)
          super
        end

        private

        def self.constraint(method, klass, flavour)
          methods[:name].like(method) & klasses[:name].like(klass) &
            { methods[:flavour] => flavour }
        end
      end
    end
  end
end
