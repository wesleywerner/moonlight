--- Getting started with Moonlight.
-- Browse the @{moonlight} api to learn all about this game.

-- add moonlight to the package path
package.path = package.path .. ";./moonlight/?.lua"

-- load moonlight
local ml = require("moonlight")

-- build the world as nested tables
ml:setWorld ({
	-- our first room. all rooms must live on the root of the world table.
	{
		-- the room name is also used to reference in the room exits
		name = "West of House",
		-- the words displayed when looking
		description = "You are standing in an open field west of a white house, with a boarded front door.",
		-- possible exits from this room
		exits = {
			south = "South of the House"
		},
		-- this room contains...
		contains = {
			-- a person
			{ name = "You", person = true },
			-- a mailbox
			{
				name = "small mailbox",
				-- a closed container won't reveal it's contents until opened
				closed = true,
				-- the mailbox contains
				contains = {
					-- only one thing in this mailbox
					{
						name = "leaflet",
						description = [[WELCOME TO ZORK!
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
		-- TODO if our room does not have a contains table we error.
		-- Validate rooms on turns.
		contains = {}
	},
	-- our third room
	{
		name = "Behind House",
		description = "You are behind the white house. A path leads into the forest to the east. In one corner of the house there is a small window which is slightly ajar.",
		exits = {
			west = "South of the House"
		},
		-- TODO if our room does not have a contains table we error.
		-- Validate rooms on turns.
		contains = {}
	}
})

-- set simulator options:

-- list contents of containers when opened.
ml.options.auto["list contents of opened"] = true

-- always print the exits of a room.
ml.options.auto["describe exits"] = true

-- set the player
ml:setPlayer ("You")

-- print a welcome message
io.write("\nWelcome! Enter 'bye' or 'quit' when done exploring.\n\n")

-- begin the game
while true do

	io.write(ml.room.name .. " > ")
	local input = io.read()

	if input == "q" or input == "quit" or input == "bye" or input == "exit" then
		break
	end

	--io.write(string.format("(turn number %d)\n", ml.turnNumber))

	-- simulate the world
	ml:turn (input)

	-- print all the responses
	--for _, message in ipairs(ml.log) do
	--	io.write(message, "\n")
	--end

	for _, message in ipairs(ml.responses) do
		io.write(message, "\n")
	end

	io.write("\n")

end
