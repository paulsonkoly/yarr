require 'cinch'
require 'yarr'

bot = Cinch::Bot.new do
  yarr = Yarr::Bot.new(self)
  yconfig = Yarr.config

  configure do |c|
    c.server = 'irc.freenode.org'
    c.nick = yconfig.nick
    c.channels = yconfig.channels

    c.username = yconfig.username
    c.password = yconfig.password
    c.port = 6697
    c.ssl.use = true
    c.ssl.verify = true
    c.sasl.username = yconfig.username
    c.sasl.password = yconfig.password
  end

  on :message, /\A&(.*)\z/ do |m, match|
    m.reply yarr.reply_to(match, m.user)
  end
end

bot.loggers.level = :debug
bot.start
