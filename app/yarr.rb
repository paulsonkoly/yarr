require 'cinch'
require 'yarr'

yarr = Yarr::Bot.new
yconfig = Yarr.config

bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.org'
    c.nick = yconfig.nick
    c.channels = yconfig.channels
    c.username = yconfig.username
    c.password = yconfig.password
  end

  on :message, /\A& *(.*)\z/ do |m, match|
    m.reply yarr.reply_to(match)
  end
end

bot.loggers.clear
bot.loggers << Cinch::Logger::FormattedLogger.new(File.open("log/log.txt", "a"))
bot.loggers.level = :info

Process.daemon(true)
bot.start
