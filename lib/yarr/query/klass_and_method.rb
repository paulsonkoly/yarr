module Yarr
  module Query
    class KlassAndMethod
      def initialize(klass, method)
        @klass = klass
        @method = method
      end

      attr_reader :klass, :method

      def to_s
        delim = case method.flavour
                when 'instance' then ?#
                when 'class' then ?.
                end
        "#{klass}#{delim}#{method}"
      end

      def self.query(method:, klass:, flavour:, allow_like: false)
        constraint =
          if allow_like
            Sequel[:methods][:name].like(method) &
            Sequel[:classes][:name].like(klass) &
            { Sequel[:methods][:flavour] => flavour }
          else
           { Sequel[:methods][:name] => method,
             Sequel[:classes][:name] => klass,
             Sequel[:methods][:flavour] => flavour }
          end

        dataset = DB[:classes]
          .join(:methods, class_id: :id)
          .select(Sequel[:methods][:name].as(:method_name),
                  Sequel[:methods][:url].as(:method_url),
                  Sequel[:methods][:flavour].as(:method_flavour),
                  Sequel[:classes][:name].as(:class_name),
                  Sequel[:classes][:url].as(:class_url))
          .where(constraint)

        Result.new(dataset, -> row {
          new(Klass::Base.new(row[:class_name], row[:class_url]),
              Method::Base.new(row[:method_name], row[:method_url], row[:method_flavour], row[:class_id]))
        })
      end
    end
  end
end
