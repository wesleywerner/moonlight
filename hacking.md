# Hacking on Moonlight

This document explains how moonlight is implemented, if you want to hack on moonlight to add features or fix bugs, this is for you.

# Setup

You will need:

* [Lua 5.x](http://www.lua.org/) - 5.2 recommended
* [Lua Rocks](https://luarocks.org/) - for installing busted & friends
* [busted](http://olivinelabs.com/busted) - unit test framework
* [LuaCov](http://keplerproject.github.io/luacov/) - code coverage analyzer

Install Lua and LuaRocks first, then install these rocks:

```
luarocks install luacheck
luarocks install busted
luarocks install penlight
luarocks install luacov
```

## Code Linting

Check the source code:

```
luacheck --no-unused-args src/*.lua
```

Check the tests (ignores the busted global variable):

```
luacheck --no-unused-args --std max+busted tests/*.lua
```

## Unit Testing

```
busted
```

Code Coverage is performed every time `busted` is invoked. Generate a report with `luacov`:

```
busted && luacov
tail -n 30 luacov.report.out
```

## Documentation Generation

LDoc is used to generate documentation for the source code, it is included as a git submodule. It requires the penlight rock, which may already be installed as a dependency if you installed `busted` earlier.

```
git submodule init && git submodule update
```

Run generation:

```
lua LDoc/ldoc.lua .
lua LDoc/ldoc.lua --dir site/api .
```

# Guides

## Extending collections onto things

World things have various collections: things contained, things supported, things hidden, parts of things... To add another such collection add support for the new collection in these functions:

`list_room_nouns`: so that the children of the new collection are listed in known nouns.
`search`: so that the simulator can locate the child things when resolving names to objects.
`list_contents`: if you want the children of the new collection listed in item descriptions.
