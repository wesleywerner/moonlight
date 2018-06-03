# lantern

An Interactive Fiction engine written in MoonScript.

# building

* Install https://luarocks.org/ then:

> luarocks install moonscript --local
> luarocks install busted --local
> luarocks install luacov --local

The `--local` option bypasses requiring super user privileges, you must add the output of `luarocks path` to your environment so that the rocks can be found by Lua.

# testing

Execute `busted`

# license

