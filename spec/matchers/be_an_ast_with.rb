RSpec::Matchers.define :be_an_ast_with do |expected|
  match do |actual|
    expected.all? { |k, v| actual[k] == v }
  end
end
