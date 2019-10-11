# moonlight user's guide

* Getting Started
* The World Model
  * Definition
    * Rooms
    * People
    * Things
    * Furniture (containers, supporters)
    * Doors and Keys
  * Validation
* Taking Turns
* Rules
  * The Standard Rules
  * Adding Rules
  * Removing Rules
* Simulator Options
  * Default Actions
  * Parser Behaviour

# Getting Started

Moonlight is written in pure Lua, this means it can be easily embedded in new and existing projects.
It also allows us to create quick and easy prototypes with the standard Lua libraries.

```
local ml = require("moonlight")
```

Moonlight expects it's rule files to be in the current path. If you opt to have Moonlight in a subdirectory you should add that path to `package.path` so that the rules (and other auxiliary) files can be found:

```
package.path = package.path .. ";./moonlight/?.lua"
local ml = require("moonlight")
```
