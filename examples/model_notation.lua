--- Moonlight world model notation examples.
-- Browse the @{moonlight} api to learn all about this game.

-- Add moonlight dependencies to the path.
package.path = package.path .. ";./moonlight/?.lua"

-- Load moonlight and scaffold modules
local moonlight = require("moonlight")
local scaffold = require("scaffold")

-- The model notation follows these rules:
-- 1. Indentation is 2 spaces.
-- 2. Rooms start with no indentation.
-- 3. A "name: value" line is a property.
-- 4. A "name:" line creates a new compound property
--    i.e. a table of properties.
-- 5. A line without a colon creates a new thing.
-- 6. A line that begins with "--" is a comment.
-- 7. "true"/"yes" and "false"/"no" are synonyms.

-- The following model recreates the "getting started" example in model notation.
--   FIX: allow empty compound properties.
local world_notation = [[
Kitchen
  description: You are in a large, kitchen. It is clean and spartan.
  exits:
    south: Lounge
  contains:
    Carrie
      person: yes
      contains:
        pocket lint
          description: You are baffled how does this stuff always make it into your pockets.
          article: some
    fridge
      description: A double-door fridge with a brushed metal finish.
      closed: yes
      locked: yes
      fixed: yes
      contains:
        pizza slice
          description: A slice of left-over pizza, margarita - your favorite!
          edible: yes
Lounge
  description: You are in a sparse lounge.
  exits:
    north: Kitchen
  contains:
    couch
      description: It is a tan couch. It looks like things could hide within it.
      fixed: yes
      -- hidden things are found when you "search the couch"
      hides:
        silver key
          description: A flat silver key.
          unlocks:
            "fridge"
            "secret door"
]]

local world_model = scaffold.build(world_notation)
--require 'pl.pretty'.dump(world_instance)
local warnings, errors = moonlight:load_world (world_model)

if #warnings > 0 then
	print("Note these warnings in your model:")
	for _, message in ipairs (warnings) do
		print(message)
	end
end
if #errors > 0 then
  print("Errors in your model will prevent you from running the simulation:")
	for _, message in ipairs (errors) do
		print("Error: ", message)
	end
end

-- Set the option to always try take things found while searching
moonlight.options.flags["take things searched"] = true

-- Set the option to auto open things when unlocking them
moonlight.options.flags["open unlocked things"] = true

-- Set the player character by name
moonlight:set_player ("Carrie")

-- Print a welcome message
io.write("\nWelcome! You can LOOK AT things, OPEN things, TAKE things, GO north, UNLOCK thing WITH thing, and SEARCH. Type BYE or EXIT to end the game.\n\n")

-- Examine the current room on first run
moonlight:turn ("look")

-- Begin the game
while true do

	-- display the previous response
	for _, message in ipairs(moonlight.output) do
		io.write(message, "\n")
	end
	io.write("\n")

	-- print the current room name and input prompt
	io.write(moonlight.room.name .. "\n> ")
	local input = io.read()

	-- end this game
	if input == "q" or input == "quit" or input == "bye" or input == "exit" then
		break
	end

	-- simulate the world using the player's input
	moonlight:turn (input)

end
