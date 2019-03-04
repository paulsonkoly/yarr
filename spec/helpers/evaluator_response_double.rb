require 'yarr/evaluator_service'

# partial double for the evaluator service responses
def evaluator_response_double(stderr: '', stdout:)
  response = Yarr::EvaluatorService::Response.new('{}')

  allow(response).to receive(:stdout).and_return(stdout)
  allow(response).to receive(:stderr).and_return(stderr)
  allow(response).to receive(:url).and_return('http://fake.com/evaluated')
  response
end
