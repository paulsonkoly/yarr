# frozen_string_literal: true

require 'yarr/dependencies'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # evaluates the content fetched from a url on an online evaluator service
    # like carc.in
    class URLEvaluate < Base
      extend Concern::ASTDigger
      digger :url

      include Import[
        'services.evaluator_service',
        'services.evaluator_service.request',
        'services.fetch_service'
      ]

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast.key? :url_evaluate
      end

      # Runs the command
      def handle
        user_content = fetch_service.get(url)
        response_code = user_content.response_code
        unless response_code == 200
          return "Request returned response code #{response_code}"
        end

        evaluator_request = request.new(user_content.body)
        evaluator_service.request(evaluator_request).output
      end
    end
  end
end
