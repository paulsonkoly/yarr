require 'cinch'
require 'xdg'
require 'yaml'

require 'yarr/config_file'

config_file = Yarr::ConfigFile.new

bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.nick = 'rubydoc'
    c.channels = [ '#nonsense' ]
    c.username = config_file.username
    c.password = config_file.password
  end

  on :message, /\A&ri (.*)\z/ do |m, match|
    match.tr! ?#, ?:
    m.reply "https://www.rubydoc.info/stdlib/core/#{match}"
  end
end

bot.start
