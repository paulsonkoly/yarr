# frozen_string_literal: true

require 'dry-container'
require 'dry-auto_inject'
require 'yarr/evaluator_service'

module Yarr
  # Dry ruby style dependnecy container
  class Dependencies
    extend Dry::Container::Mixin

    namespace :services do
      register('evaluator_service') { EvaluatorService.new }
      register('evaluator_service.request') { EvaluatorService::Request }
      register('fetch_service') { Typhoeus }
    end
  end

  Import = Dry::AutoInject(Dependencies)
end
