# TODO
# rubocop:disable Metrics/MethodLength
def environment_variable(name)
  before do
    @original_setting = ENV[name]
    yield
  end

  after do
    if @original_setting.nil?
      ENV.delete(name)
    else
      ENV[name] = @original_setting
    end
  end
end
# rubocop:enable Metrics/MethodLength
