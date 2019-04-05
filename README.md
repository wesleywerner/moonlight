# moonlight

[![Coverage Status](https://coveralls.io/repos/github/wesleywerner/moonlight/badge.svg?branch=master)](https://coveralls.io/github/wesleywerner/moonlight?branch=master)

Moonlight is an interactive fiction world simulator.

It takes care of parsing player sentences, matching the known nouns
in the current room, and simulates world interactions.

Moonlight uses a rule based system to define when and what actions do.

This documentation contains everything you need to learn how to use
Moonlight, including a bunch of working examples.

See @{getting_started.lua} for a quick introduction.

# development

Moonlight development, unit testing and document generation requirements:

* [Lua 5.x](http://www.lua.org/) - 5.2 recommended
* [Lua Rocks](https://luarocks.org/)

## luarocks

Build luarocks from source is advised, you need the lua headers for this:

	sudo apt-get install liblua5.2-dev

Then from the luarocks source directory:

	./configure
	make build
	make install

## set your lua path

To ensure lua looks for these modules in your local rocks, set your `LUA_PATH` environment variable (in .bash_profile for example):

	# local luarocks bin
	export PATH=~/.luarocks/bin:$PATH

	# set LUA_PATH
	eval "$(luarocks path)"

## required rocks

	luarocks install luacheck --local && \
	luarocks install busted --local && \
	luarocks install penlight --local && \
	luarocks install luacov --local

The `--local` option bypasses requiring super user privileges, you must add the output of `luarocks path` to your environment so that the rocks can be found by Lua.

## linting

Check the code syntax:

	luacheck --no-unused-args src/*.lua

Check the syntax of the tests by ignoring the busted global:

	luacheck --no-unused-args --std max+busted tests/*.lua

## running unit tests

Unit testing is done with busted, the `.busted` config already defines everything, so simply run:

	busted

Check code coverage:

Coverage is performed every time `busted` is run. Generate the report with `luacov`:

	busted && luacov

	# check the tail for the summary
	less luacov.report.out

## document generation

LDoc is used to generate documentation for the source code, it is included as a git submodule. It requires the penlight rock, which may already be installed as a dependency if you installed `busted` earlier.

	# pull the LDoc submodule
	git submodule init && git submodule update

Run generation:

	lua LDoc/ldoc.lua .
