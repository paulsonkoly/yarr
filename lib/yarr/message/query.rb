require 'yarr/database'

module Yarr
  module Message
    module Query
      def joined_query(method:, klass:, flavour:)
        DB[:classes]
          .join(:methods, class_id: :id)
          .where(Sequel[:methods][:name] => method,
                 Sequel[:classes][:name] => klass,
                 Sequel[:methods][:flavour] => flavour)
      end

      def klass_query(klass)
        DB[:classes].where(name: klass)
      end

      def method_query(method)
        DB[:methods].where(name: method)
      end

      def joined_like_query(method:, klass:, flavour:)
        DB[:classes]
          .join(:methods, class_id: :id)
          .select(Sequel[:methods][:name].as(:method_name),
        Sequel[:classes][:name].as(:class_name))
          .where(Sequel[:methods][:name].like(method) &
        Sequel[:classes][:name].like(klass) &
        { Sequel[:methods][:flavour] => flavour })
      end

      def klass_like_query(klass)
        Yarr::DB[:classes].where(Sequel[:name].like(klass))
      end

      def method_like_query(klass:, method:)
        Yarr::DB[:classes]
          .join(:methods, class_id: :id)
          .select(Sequel[:methods][:name].as(:method_name),
                  Sequel[:classes][:name].as(:class_name),
                  Sequel[:methods][:flavour].as(:method_flavour))
          .where(Sequel[:methods][:name].like(method))
      end
    end
  end
end
