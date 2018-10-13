require 'forwardable'

module Yarr
  module Query
    # Contains the database objects in an enumerable.
    class Result
      extend Forwardable
      include Enumerable

      # @api private
      # @param dataset [Sequel::Dataset] query result
      # @param transformer [Proc] transforms dataset lines into {Query} objects
      def initialize(dataset, transformer)
        @dataset = dataset
        @transformer = transformer
      end

      def_delegator :@dataset, :count

      # Yields database objects from a dataset
      # @yieldparam object the database object
      def each
        @dataset.each { |data| yield(@transformer.call(data)) }
      end
    end
  end
end
