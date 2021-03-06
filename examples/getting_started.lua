--- Getting started with Moonlight.
-- Browse the @{moonlight} api to learn all about this game.

-- Add moonlight to the package path. This is so that moonlight
-- finds all it's dependencies.
package.path = package.path .. ";./moonlight/?.lua"

-- Load moonlight
local ml = require("moonlight")

-- Create your world. Note how no functions are placed in the model.
local myworld = {
	-- Rooms are defined as a list of tables. Our first room.
	{
		name = "Kitchen",
		description = "You are in a large open plan kitchen that is clean and tidy and spartan.",
		-- List of things in this room
		contains = {
			{
				name = "Carrie",
				person = true,
				-- This person is carrying some things
				contains = {
					{
						name = "pocket lint",
						description = "You are baffled how does this stuff always make it into your pockets.",
						-- set the article of the lint so it reads "some pocket lint", and not "a pocket lint"
						article = "some"
					}
				}
			},
			{
				name = "fridge",
				description = "A double-door fridge with a brushed metal finish.",
				-- It is closed, hiding whatever is inside
				closed = true,
				-- It is locked, and needs a key to open
				locked = true,
				-- It cannot be taken
				fixed = true,
				-- Things inside the fridge
				contains = {
					{
						name = "pizza slice",
						description = "A slice of left-over pizza, margarita - your favorite!",
						-- The player can consume it
						edible = true
					}
				}
			}
		},
		-- List exits out of this room
		exits = {
			south = "Lounge"
		}
	},
	-- Add a second room to our world
	{
		name = "Lounge",
		description = "You are in a sparse lounge.",
		contains = {
			{
				name = "couch",
				description = "It is a tan couch. It looks like things could hide within it.",
				-- It cannot be taken
				fixed = true,
				-- The couch can have things on top of it.
				supports = { },
				-- Something is hidden in the couch.
				-- It can be found by SEARCHing
				hides = {
					{
						name = "silver key",
						description = "A flat silver key.",
						-- This key unlocks the fridge.
						-- This property is a table so we can
						-- list multiple things to unlock.
						unlocks = {
							"fridge"
						}
					}
				},
			}
		},
		exits = {
			north = "Kitchen"
		}
	}
}

-- Load the world model.
-- Demonstrate listing any potential issues with your model.
local warnings, errors = ml:load_world (myworld)

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
ml.options.flags["take things searched"] = true

-- Set the option to auto open things when unlocking them
ml.options.flags["open unlocked things"] = true

-- Set the player character by name
ml:set_player ("Carrie")

-- Print a welcome message
io.write("\nWelcome! You can LOOK AT things, OPEN things, TAKE things, GO north, UNLOCK thing WITH thing, and SEARCH. Type BYE or EXIT to end the game.\n\n")

-- Examine the current room on first run
ml:turn ("look")

-- Begin the game
while true do

	-- display the previous response
	for _, message in ipairs(ml.output) do
		io.write(message, "\n")
	end
	io.write("\n")

	-- print the current room name and input prompt
	io.write(ml.room.name .. "\n> ")
	local input = io.read()

	-- end this game
	if input == "q" or input == "quit" or input == "bye" or input == "exit" then
		break
	end

	-- simulate the world using the player's input
	ml:turn (input)

end
