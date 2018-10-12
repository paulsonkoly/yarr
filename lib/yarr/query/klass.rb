module Yarr
  module Query
    class Klass
      def initialize(name, url)
        @name = name
        @url = url
      end

      attr_reader :name, :url

      def to_s
        @name
      end

      def self.query(name:, allow_like: false)
        constraint = allow_like ? Sequel[:name].like(name) : { name: name }
        dataset = DB[:classes].where(constraint)
        Result.new(dataset, -> row {
          new(row[:name], row[:url])
        })
      end
    end
  end
end
