# frozen_string_literal: true

RSpec.shared_context 'with environment variable' do |environment_variables|
  before do
    @original_setting = {}

    environment_variables.each do |name, value|
      @original_setting[name] = ENV[name] if ENV.key? name
      ENV[name] = value.to_s
    end
  end

  after do
    @original_setting.each { |name, value| ENV[name] = value }
  end
end
