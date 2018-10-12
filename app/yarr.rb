require 'cinch'
require 'yarr'

config_file = Yarr::ConfigFile.new
yarr = Yarr::Bot.new

bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.nick = 'rubydoc'
    c.channels = [ '#rubydoc_test' ]
    c.username = config_file.username
    c.password = config_file.password
  end

  on :message, /\A& *(.*)\z/ do |m, match|
    m.reply yarr.reply_to(match)
  end
end

bot.start
