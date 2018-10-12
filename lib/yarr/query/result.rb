require 'forwardable'

module Yarr
  module Query
    class Result
      extend Forwardable
      include Enumerable

      def initialize(dataset, transformer)
        @dataset = dataset
        @transformer = transformer
      end

      def_delegator :@dataset, :count

      def each
        @dataset.each { |data| yield(@transformer.call(data)) }
      end
    end
  end
end
