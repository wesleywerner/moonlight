--- Getting started with Moonlight.
-- Browse the @{moonlight} api to learn all about this game.

-- Add moonlight to the package path. This is so that moonlight
-- finds all it's other modules.
package.path = package.path .. ";./moonlight/?.lua"

-- Load moonlight
local ml = require("moonlight")

-- Load the world model
ml:setWorld ({
	{
		name = "White Room",
		description = "The room glows with a soft white light.",
		contains = {
			{
				name = "Freddie",
				person = true,
				description = "Good looking as ever."
			},
			{
				name = "red key",
				unlocks = { "red door" }
			},
			{
				name = "blue key",
				unlocks = { "blue door" }
			},
			{
				name = "green key",
				unlocks = { "green door" }
			},
			{
				name = "red door",
				fixed = true,
				closed = true,
				locked = true,
				destination = "Red Room"
			},
			{
				name = "green door",
				fixed = true,
				closed = true,
				locked = true,
				destination = "Green Room"
			},
			{
				name = "blue door",
				fixed = true,
				closed = true,
				locked = true,
				destination = "Blue Room"
			},

		}
	},
	{
		name = "Red Room",
		description = "The room glows an eerie colour.",
		exits = {
			out = "White Room"
		},
	},
	{
		name = "Green Room",
		description = "The room glows an eerie colour.",
		exits = {
			out = "White Room"
		},
	},
	{
		name = "Blue Room",
		description = "The room glows an eerie colour.",
		exits = {
			out = "White Room"
		},
	},

})

-- Auto list the exits out of the current room
ml.options.auto["list exits"] = true

-- Set the player character by name
ml:setPlayer ("Freddie")

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
