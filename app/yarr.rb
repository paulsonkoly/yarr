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

  on :message, %r{\A&(?<override>[a-z0-9]+)?>>(?!>)(?<code>.*)} do |m, override, code|
    m.reply begin
      evaluator = Yarr::Evaluator.new(override)
      evaluator.evaluate(code)
    rescue StandardError => e
      "I'm terribly sorry, I could not evaluate your code because of an error: #{e.class}:#{e.message}"
    end
  end

  on :message, /\A&((list|ri|ast|fake)(?!>>) +.*)\z/ do |m, match|
    m.reply yarr.reply_to(match)
  end
end

if Yarr.config.development?
  bot.loggers.level = :debug
else
  bot.loggers.clear
  logger = Cinch::Logger::FormattedLogger.new(File.open('log/log.txt', 'a'))
  bot.loggers << logger
  bot.loggers.level = :info

  Process.daemon(true)
end

bot.start
