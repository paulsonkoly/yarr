# Yarr

This application is the workhorse behind the rubydoc bot on freenode.net #ruby.

[![Build Status](https://travis-ci.org/phaul/yarr.svg?branch=master)](https://travis-ci.org/phaul/yarr)
[![Maintainability](https://api.codeclimate.com/v1/badges/4a48c3a34babe2af4e8f/maintainability)](https://codeclimate.com/github/phaul/yarr/maintainability)

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

### ri

ri looks up the documentation of a class name, a method name, an instance
method call (in the form of `ri Array#size`) and a class method call (in the
form of `ri File.size`). If the query is ambiguous the bot will tell you that.

```
ri instance_methods
>>> https://ruby-doc.org/core-2.5.1/Module.html#method-i-instance_methods
ri puts
>>> I found 3 entries matching with method: puts. Use &list puts if you would like to see a list
```

### list

list lists the matching names. % is taken as a wildcard character that can
match any string fragment.

```
list puts
>>> ARGF#puts, IO#puts, Kernel#puts
list %!
>>> BasicObject#!, String#capitalize!, String#chomp!, String#chop!, Array#collect!, Array#compact!, Hash#compact!, String#delete!, String#delete_prefix!,...
```

For ambiguous method names we simply call list:

```
list size
>>> ENV.size, File.size, Array#size, Enumerator#size, File#size, File::Stat#size, FileTest#size, Hash#size, Integer#size, MatchData#size,...
```

One caveat is that yarr decides if a token is a class name or not by checking
if the first character is upcase. Therefore we can't list the File class this
way:

```
list %ile
>>> Enumerable#chunk_while, Enumerator::Lazy#chunk_while, Regexp.compile, RubyVM::InstructionSequence.compile, RubyVM::InstructionSequence.compile_file,...
```

However it is possible to force it to be part of a class or module name by this trick:

```
list %ile.% 
>>> File.absolute_path, File.atime, File.basename, File.birthtime, File.blockdev?, File.chardev?, File.chmod, File.chown, File.ctime, File.delete,...
```

### what_is

what_is is a debug command. We can ask the bot about a particular token:

```
what_is File
>>> It's a(n) class name.
what_is size
>>> It's a(n) method name.
what_is File.size
>>> It's a(n) class method.
what_is File#size
>>> It's a(n) instance method.
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/phaul/yarr.

The `lint:all` rake task kicks of a bunch of checks on the project including
module level coverage. This asserts that each module in the project is 100%
covered by it's corresponding spec in isolation. For this to work you need to
patch simplecov and simplecov-html with branch coverage support. `lint:all`
should all pass.

API documentation can be found
[rubydoc.info](https://www.rubydoc.info/github/phaul/yarr/master).
