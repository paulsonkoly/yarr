require 'forwardable'

module Yarr
  # The parsed user input
  class AST
    extend Forwardable

    # Constructs an AST from a hash produced by the parser
    # @param hash [Hash] parslet output
    def initialize(hash)
      @hash = stringify_hash_values(hash)
    end

    # @!method []
    #   Accesses an immediate AST sub node by key
    # @!method key?(sym)
    #   @param sym [Symbol] ast key
    #   Is the given symbol at the top level of the AST

    def_delegator :@hash, :[]
    def_delegator :@hash, :key?
    def_delegator :@hash, :to_s
    def_delegator :@hash, :include?

    # Looks up a key traversing the AST recursively
    # @param key [Symbol] AST key
    # @return [Object|nil] AST node stored under key if any
    def dig_deep(key)
      self.class.send(:dig_deep, @hash, key)
    end

    private

    def stringify_hash_values(hash)
      hash.transform_values do |value|
        case value
        when Hash then stringify_hash_values(value)
        else value.to_s
        end
      end
    end

    def self.dig_deep(hash, key)
      return unless hash.is_a? Hash
      return hash[key] if hash.key? key

      hash.values.map { |elem| dig_deep(elem, key) }.find(&:itself)
    end
    private_class_method :dig_deep
  end
end
