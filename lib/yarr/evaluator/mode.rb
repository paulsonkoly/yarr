# frozen_string_literal: true

require 'dry-initializer'
require 'dry-types'

module Yarr
  # A wrapper on a web request that uses carc.in
  module Evaluator
    # Form object for evaluator mode loaded from config.yml
    class Mode
      extend Dry::Initializer

      option :filter, type: Dry::Types['hash'].map(Dry::Types['strict.string'], Dry::Types['strict.string'])
      option :output, type: Dry::Types['strict.symbol'].constrained(included_in: %i[truncate link])
      option :format, type: Dry::Types['strict.string'] |
                            Dry::Types['hash'].map(Dry::Types['strict.symbol'], Dry::Types['strict.string'])
      option :verb, type: Dry::Types['strict.string'].optional, default: -> { nil }
    end
  end
end
