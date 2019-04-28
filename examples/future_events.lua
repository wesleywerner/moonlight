--- Getting started with Moonlight.
-- Browse the @{moonlight} api to learn all about this game.

-- Add moonlight to the package path. This is so that moonlight
-- finds all it's other modules.
package.path = package.path .. ";./moonlight/?.lua"

-- Load moonlight
local ml = require("moonlight")

-- Load the world model
ml:load_world ({
	{
		name = "The Kitchen",
		description = "Your kitchen is spartan.",
		contains = {
			{
				name = "Freddie",
				person = true,
				description = "Good looking as ever."
			},
			{
				name = "table",
				fixed = true,
				supports = {
					{
						name = "pot of coffee",
						edible = true
					},
					{
						name = "crumbs",
						article = "some",
						description = "From last night's pizza.",
						-- TODO set fixed message in the model
						--fixed = ""
					}
				}
			},
			{
				name = "fridge",
				description = "",
				closed = true,
				fixed = true,
				contains = {
					{
						name = "slice of pizze",
						description = "Margarita with chillie.",
						edible = true
					}
				}
			},
			{
				name = "oven",
				fixed = true,
				contains = {
					{
						name = "cake",
						description = "A chocolate cake."
					},
				}
			},

		}
	},
})

-- Auto list contents of containers when opened
ml.options.auto["list contents of opened"] = true

-- Set the player character by name
ml:set_player ("Freddie")

-- Print a welcome message
io.write("\nWelcome to the getting started game. You can LOOK AT things, OPEN things, UNLOCK things WITH keys, or ENTER doors. BYE or EXIT ends the game.\n\n")

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
	io.write(ml.room.name .. " > ")
	local input = io.read()

	-- end this game
	if input == "q" or input == "quit" or input == "bye" or input == "exit" then
		break
	end

	-- simulate the world using the player's input
	ml:turn (input)

end
