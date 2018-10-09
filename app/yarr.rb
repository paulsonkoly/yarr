require 'cinch'
require 'yaml'

YARR_CONFIG = File.join(ENV['HOME'], 'yarr.yml')
$yarr = File.open(YARR_CONFIG, 'r') { |io| YAML.load(io.read) }

bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.nick = 'rubydoc'
    c.channels = [ '#nonsense' ]
    c.username = $yarr[:username]
    c.password = $yarr[:password]
  end

  on :message, /\A&ri (.*)\z/ do |m, match|
    match.tr! ?#, ?:
    m.reply "https://www.rubydoc.info/stdlib/core/#{match}"
  end
end

bot.start
