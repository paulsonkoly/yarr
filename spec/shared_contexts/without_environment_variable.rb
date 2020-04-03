# frozen_string_literal: true

RSpec.shared_context 'without environment variable' do |environment_variables|
  before do
    @original_setting = {}

    [*environment_variables].each do |name|
      @original_setting[name] = ENV[name] if ENV.key? name
      ENV.delete(name)
    end
  end

  after do
    @original_setting.each { |name, value| ENV[name] = value }
  end
end
