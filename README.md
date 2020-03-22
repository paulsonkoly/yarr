# Yarr

This application is the workhorse behind the rubydoc bot on freenode.net #ruby.

[![Build Status](https://travis-ci.org/phaul/yarr.svg?branch=master)](https://travis-ci.org/phaul/yarr)
[![Maintainability](https://api.codeclimate.com/v1/badges/4a48c3a34babe2af4e8f/maintainability)](https://codeclimate.com/github/phaul/yarr/maintainability)
[![Inline docs](http://inch-ci.org/github/phaul/yarr.svg?branch=master)](http://inch-ci.org/github/phaul/yarr)

## Installation

```bash
$ cd yarr
$ bundle install
```

## Configuration

Copy the configuration sample:

```bash
$ cp config/yarr_sample.yml config/yarr.yml
```

Edit the `config/yarr.yml` file, fill in the blanks.

Set up the database and load it with default data:

```
$ rake db:setup
```

## Usage

You can run the bot, or you can run yarr in a console (no IRC connection).
To run the application you have to run the following command:

```bash
$ bundle exec ruby bin/console # run console mode.
$ bundle exec ruby app/yarr # run bot mode.
```

In irc mode all commands have to be prefixed with `&'.

### >>

Evaluates arbitrary ruby code by posting it to carc.in and then links the
result. Ruby version can be specified by prepending it to >>, like 20>>, 21>>
etc. The command can be modified to send a disassembly, tokenisation, or parse
request on the code to carc.in. These modifiers can also be combined with the
ruby version, action modifier comes first.

 |          |                                        |
 | :------- | :------------------------------------- |
 | `asm`    | dissassemble                           |
 | `tok`    | lexer output                           |
 | `ast`    | parser output                          |
 | `bare`   | bare code (no implicit p or begin/end) |

```
&>> 1 + 1
>>> => 2 (http://...)
&asm20>> 1 + 1
>>> I have disassembled your code, the result is at http://...
```

### url

The url command fetches the source that is sent to the evaluation service from
a user specified url. This is useful if we want to evaluate for instance a gist
with the bot.

```
&url http://somegist.raw/gist.rb
>>> # => 13 (http://...)
```

### ri

ri looks up the documentation of a class name, a method name, an instance
method call (in the form of `ri Array#size`) and a class method call (in the
form of `ri File.size`). If the query is ambiguous the bot will tell you that.

```
&ri instance_methods
>>> https://ruby-doc.org/core-2.5.1/Module.html#method-i-instance_methods
&ri puts
>>> I found 3 entries matching with method: puts. Use &list puts if you would like to see a list
```

#### Class or module name ambiguity

In case of class or module names ri implicitly resolves ambiguous names if
there is a definition in core (no file needs to be required to use the class)
or if the required file matches the class name. This helps when classes are
patched in multiple places and we just want to get the url of the main
documentation. We can list all names, or be explicit in the query.

```
&ri Array
>>> https://ruby-doc.org/core-2.5.1/Array.html
&list Array
>>> Array, Array (abbrev), Array (mkmf), Array (rexml), Array (shellwords)
&ri Array (mkmf)
>>> https://ruby-doc.org/stdlib-2.5.1/libdoc/mkmf/rdoc/Array.html
```


### list

list lists the matching names. % is taken as a wildcard character that can
match any string fragment.

```
&list puts
>>> ARGF#puts, IO#puts, Kernel#puts
&list %!
>>> BasicObject#!, String#capitalize!, String#chomp!, String#chop!, Array#collect!, Array#compact!, Hash#compact!, String#delete!, String#delete_prefix!,...
```

For ambiguous method names we simply call list:

```
&list size
>>> ENV.size, File.size, Array#size, Enumerator#size, File#size, File::Stat#size, FileTest#size, Hash#size, Integer#size, MatchData#size,...
```

One caveat is that yarr decides if a token is a class name or not by checking
if the first character is upcase. Therefore we can't list the File class this
way:

```
&list %ile
>>> Enumerable#chunk_while, Enumerator::Lazy#chunk_while, Regexp.compile, RubyVM::InstructionSequence.compile, RubyVM::InstructionSequence.compile_file,...
```

However it is possible to force it to be part of a class or module name by this trick:

```
&list %ile.%
>>> File.absolute_path, File.atime, File.basename, File.birthtime, File.blockdev?, File.chardev?, File.chmod, File.chown, File.ctime, File.delete,...
```

### renick

If during a reconnect the bot lost its default nick, this command will try to regain it.

### ops

Lists current channel operators. Can be used to mention all operators in the channel if you want operator attention. Useful if the channel is trolled. Operators are users with ruby/staff mask, not necessarily with +o flag.

### facts

Responds with a factoid. Command can be triggered with the `fact` command or the `?` alias. Factoids are listed at https://ruby-community.com/ruboto/facts.

```
&? pizza
>>> here's your pizza: 🍕
```

#### factoid manipulation commands

These commands are restricted to channel operators.

 | subcommand | alias | syntax                                 |
 | :-------   | :---  | :------------------------------------- |
 | `add`      | `mk`  | `fact add <name> <content>`            |
 | `remove`   | `rm`  | `fact remove <name>`                   |
 | `edit`     | `ed`  | `fact edit <name> <content>`           |
 | `rename`   | `mv`  | `fact rename <name> <name>`            |

```
& fact add ruby An object oriented programming language.
>>> I will remember that ruby is An object oriented programming language.
& ? ruby
>>> An object oriented programming language.
```

### fake

An easter egg command, using Classname.methodname ri notation. It responds with
the result of Faker::Classname.methodname from the
[faker](https://github.com/stympy/faker) gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/phaul/yarr.

The `lint:all` rake task kicks off a bunch of checks on the project including
branch coverage. `bundle exec rake lint:reek` has to be clean.

### Testing

The environment variable `YARR_TEST` controls if the test database needs to be
loaded. The Rake tasks take care of this variable before kicking tasks off like
running rspec, or coverage.

API documentation can be found
[rubydoc.info](https://www.rubydoc.info/github/phaul/yarr/master).
