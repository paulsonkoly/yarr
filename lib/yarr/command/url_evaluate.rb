require 'yarr/evaluator_service'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # evaluates the content fetched from a url on an online evaluator service
    # like carc.in
    class URLEvaluate < Base
      extend Concern::ASTDigger
      digger :url

      def self.match?(ast)
        ast.key? :url_evaluate
      end

      # @param ast [Yarr::AST] user input
      # @param fetch_service [#get] A web service that can get
      # @param evaluator_service [Yarr::EvaluatorService] the evaluator
      def initialize(ast,
                     fetch_service = Typhoeus,
                     evaluator_service = EvaluatorService.new)
        super(ast)

        @fetch_service = fetch_service
        @evaluator_service = evaluator_service
      end

      def handle
        user_content = @fetch_service.get(url)
        response_code = user_content.response_code
        unless response_code == 200
          return "Request returned response code #{response_code}"
        end

        evaluator_request = EvaluatorService::Request.new(user_content.body)
        @evaluator_service.request(evaluator_request).output
      end
    end
  end
end
