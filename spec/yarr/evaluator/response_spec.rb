# frozen_string_literal: true

require 'spec_helper'
require 'json'

require 'yarr/error'
require 'yarr/evaluator/response'

RSpec.describe Yarr::Evaluator::Response do
  subject { described_class.new(input) }
  let(:input) do
    { run_request: { run: { stderr: stderr, stdout: stdout, html_url: 'http://fake.com/evaluated' } } }.to_json
  end
  let(:stderr) { '' }
  let(:stdout) { '' }

  describe '#url' do
    it 'parses the URL correctly' do
      expect(subject.url).to eq 'http://fake.com/evaluated'
    end
  end

  describe '#output' do
    context 'with stderr content' do
      let(:stderr) { 'error occured' }

      it 'contains the error' do
        expect(subject.output).to eq 'stderr: error occured (http://fake.com/evaluated)'
      end
    end

    context 'with both stdout and stderr content' do
      let(:stdout) { 'this is the output' }
      let(:stderr) { 'this is the errror' }

      it 'contains both' do
        expect(subject.output).to eq '# => this is the output stderr: this is the errror (http://fake.com/evaluated)'
      end
    end

    context 'with an expression whose result needs truncating' do
      let(:stdout) { Faker::Lorem.paragraph_by_chars(Yarr::Message::Truncator::MAX_LENGTH + 100) }

      it 'truncates to the right size with the url' do
        expect(subject.output.length)
          .to be_within(20).of(Yarr::Message::Truncator::MAX_LENGTH)
        expect(subject.output.length)
          .to be <= Yarr::Message::Truncator::MAX_LENGTH
        expect(subject.output)
          .to end_with '... check link for more (http://fake.com/evaluated)'
      end
    end
  end

  context 'when the format is incorrect' do
    let(:input) { 'blah'.to_json }

    it 'raises UnexpectedServerResponseError' do
      expect { subject }.to raise_error Yarr::UnexpectedServerResponseError
    end
  end
end
