require 'json'
require 'typhoeus'
require 'yarr/configuration'

module Evaluator
  def evaluate_code(message, override, code)
    /\A(?<o_mode>[[:alpha:]]+)?(?<o_lang>\d{2})?/ =~ override

    config = Yarr.config.evaluator

    lang = config[:languages][o_lang || :default]
    mode = config[:modes][o_mode || :default]

    raise StandardError, 'Couldn\'t match lang/mode' unless mode && lang

    if mode[:escape]
      code.gsub!("\\", "\\\\")
      code.gsub!("`", "\\`")
    end

    code = sprintf mode[:format], code.lstrip
    payload = {run_request: {language: 'ruby', version: lang, code: code}}
    headers = {'Content-Type': 'application/json; charset=utf-8'}
    response = Typhoeus.post(config[:url], {
      body: payload.to_json,
      headers: headers
    }).response_body

    response = JSON.parse(response)

    url = response['run_request']['run']['html_url']
    output = response['run_request']['run']['stdout']

    case mode[:output]
    when :truncate
      output = "#{output.lines.first.chomp[0, 100]} ...check link for more" if output.size > 100 or output.lines.count > 1
      return "# => #{output.strip} (#{url})"
    when :link
      return "I have #{mode[:verb]} your code, the result is at #{url}"
    end
  rescue StandardError => e
    return "I'm terribly sorry, I could not evaluate your code because of an error: #{e.class}:#{e.message}"
  end

  module_function :evaluate_code
end
