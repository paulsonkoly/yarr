# frozen_string_literal: true

require 'nokogiri'
require 'typhoeus'

require_relative 'db_helper'

WEBSITE = 'https://ruby-community.com/ruboto/facts'

response = Typhoeus.get(WEBSITE)
abort "fetch response from #{WEBSITE} was code #{response.code}" unless response.code == 200

doc = Nokogiri::HTML(response.body)
doc.css('div.page-top table tr').map do |row|
  name, count, content = row.css('td').map(&:text)
  count = count.to_i

  next unless name

  p name: name, content: content, count: count
  if DB[:facts].where(name: name).update(content: content, count: count) != 1
    DB[:facts].insert(name: name, content: content, count: count)
  end
end
