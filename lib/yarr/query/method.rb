module Yarr
  module Query
    class Method
      def initialize(name, url, flavour, klass)
        @name = name
        @url = url
        @flavour = flavour
        @klass = klass
      end

      attr_reader :name, :url, :flavour, :klass

      def to_s
        @name
      end

      def self.query(name:, allow_like: false)
        if allow_like
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
        else
          dataset = DB[:methods].where(name: name)
          Result.new(dataset, -> row {
            new(row[:name], row[:url], row[:flavour], row[:class_id])
          })
        end
      end
    end
  end
end
