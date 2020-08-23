# frozen_string_literal: true

require 'yarr/evaluator/response'
require 'json'

# partial double for the evaluator service responses
def evaluator_response_double(stderr: '', stdout: '')
  Yarr::Evaluator::Response.new(
    { run_request: { run: { stderr: stderr, stdout: stdout, html_url: 'http://fake.com/evaluated' } } }.to_json
  )
end
