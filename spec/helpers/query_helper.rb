def query
  return @query if @query
  @query = double('query')

  allow(Yarr::DB).to receive(:[]).and_return(@query)

  %i[join select order].each do |sym|
    allow(@query).to receive(sym).and_return(@query)
  end

  @query
end
