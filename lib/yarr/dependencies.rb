# frozen_string_literal: true

require 'typhoeus'
require 'dry-container'
require 'dry-auto_inject'
require 'yarr/no_irc'
require 'yarr/input_parser'
require 'yarr/configuration'

module Yarr
  # Dry ruby style dependnecy container
  class Dependencies
    extend Dry::Container::Mixin

    namespace :services do
      register('evaluator_service') do
        # this being a dependency and a user of dependencies requires avoiding
        # circularity
        require 'yarr/evaluator_service'
        EvaluatorService.new
      end
      register('evaluator_service.request') { EvaluatorService::Request }
      register('fetch_service') { Typhoeus }
    end

    register('irc') { NoIRC }

    namespace :parser do
      register('input') { InputParser.new }
      register('input.parse_error') { InputParser::ParseError }
    end

    register('configuration') { Yarr.config }
  end

  Import = Dry::AutoInject(Dependencies)
end
