require 'yarr/evaluator_service'
require 'yarr/command/concern/ast_digger'

module Yarr
  module Command
    # evaluates the content fetched from a url on an online evaluator service
    # like carc.in
    class URLEvaluate < Base
      extend Concern::ASTDigger
      digger :url

      # @param ast [AST] parsed ast
      # @return [True|False] can this command handle the AST?
      def self.match?(ast)
        ast.key? :url_evaluate
      end

      # @param fetch_service [#get] A web service that can get
      # @param evaluator_service [Yarr::EvaluatorService] the evaluator
      # @see {Yarr::Base} for the rest of the arguments
      def initialize(ast:,
                     irc: NoIRC,
                     fetch_service: Typhoeus,
                     evaluator_service: EvaluatorService.new)
        super(ast: ast, irc: irc)

        @fetch_service = fetch_service
        @evaluator_service = evaluator_service
      end

      # Runs the command
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
