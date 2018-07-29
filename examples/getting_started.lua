--- Getting started with Moonlight.
-- Browse the @{moonlight} api to learn all about this game.

-- Add moonlight to the package path. This is so that moonlight
-- finds all it's other modules.
package.path = package.path .. ";./moonlight/?.lua"

-- Load moonlight
local ml = require("moonlight")

-- Load the world model
ml:setWorld ({
	-- Rooms are defined as a list of tables. This is our first room.
	{
		name = "West of House",
		description = "You are standing in an open field west of a white house.",
		exits = {
			south = "South of the House"
		},
		-- A list of things contained herein
		contains = {
			-- the player character (via setPlayer)
			{ name = "You", person = true },
			-- a mailbox
			{
				name = "small mailbox",
				-- a closed thing won't reveal it's contents until opened
				closed = true,
				-- it cannot be picked up
				fixed = true,
				-- the mailbox contains
				contains = {
					{
						name = "leaflet",
						description = [[
						WELCOME TO ZORK!
					ZORK is a game of adventure, danger, and low cunning.
					In it you will explore some of the most
					amazing territory ever seen by mortals.
					No computer should be without one!]]
					}
				},
			}
		}
	},
	-- our second room in the game
	{
		name = "South of the House",
		description = "You are facing the south side of a white house. There is no door here, and all the windows are boarded.",
		exits = {
			north = "West of House",
			east = "Behind House"
		},
	},
	-- our third room
	{
		name = "Behind House",
		description = "You are behind the white house. In one corner of the house there is a small window which is slightly ajar.",
		exits = {
			west = "South of the House"
		},
	}
})

-- Auto list contents of containers when opened
ml.options.auto["list contents of opened"] = true

-- Auto list the exits out of the current room
ml.options.auto["list exits"] = true

-- Set the player character by name
ml:setPlayer ("You")

-- Print a welcome message
io.write("\nWelcome to the getting started game. You can LOOK AT things, OPEN things, CLOSE things, GO north or ENTER doors and windows. BYE or EXIT ends the game.\n\n")

-- Examine the current room on first run
ml:turn ("look")

-- Begin the game
while true do

	-- display the previous response
	for _, message in ipairs(ml.responses) do
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
