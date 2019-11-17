# frozen_string_literal: true

require 'dry-container'
require 'dry-auto_inject'
require 'yarr/evaluator_service'
require 'yarr/no_irc'
require 'yarr/input_parser'

module Yarr
  # Dry ruby style dependnecy container
  class Dependencies
    extend Dry::Container::Mixin

    namespace :services do
      register('evaluator_service') { EvaluatorService.new }
      register('evaluator_service.request') { EvaluatorService::Request }
      register('fetch_service') { Typhoeus }
    end

    register('irc') { NoIRC }

    namespace :parser do
      register('input') { InputParser.new }
      register('input.parse_error') { InputParser::ParseError }
    end
  end

  Import = Dry::AutoInject(Dependencies)
end
