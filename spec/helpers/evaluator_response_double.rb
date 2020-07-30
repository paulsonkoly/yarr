# frozen_string_literal: true

require 'yarr/evaluator/response'

# partial double for the evaluator service responses
def evaluator_response_double(stderr: '', stdout:)
  response = Yarr::Evaluator::Response.new('{}')

  allow(response).to receive(:stdout).and_return(stdout)
  allow(response).to receive(:stderr).and_return(stderr)
  allow(response).to receive(:url).and_return('http://fake.com/evaluated')
  response
end
