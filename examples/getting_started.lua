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
		description = "You are standing in an open field west of a white house.",
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
				-- it cannot be taken
				fixed = true,
				-- the mailbox contains
				contains = {
					-- only one thing in this mailbox
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

-- set simulator options:

-- list contents of containers when opened.
ml.options.auto["list contents of opened"] = true

-- always print the exits of a room.
ml.options.auto["describe exits"] = true

-- set the player
ml:setPlayer ("You")

-- print a welcome message
io.write("\nWelcome to the getting started game. You can LOOK AT things, OPEN things, CLOSE things, GO north or ENTER doors and windows. BYE or EXIT ends the game.\n\n")

-- examine the current room automatically on first run
ml:turn ("look")

-- begin the game
while true do

	-- display the last response
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
