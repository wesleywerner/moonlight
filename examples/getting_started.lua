--- Getting started with Moonlight.
-- Browse the @{moonlight} api to learn all about this game.

-- add moonlight to the package path
package.path = package.path .. ";./moonlight/?.lua"

-- load moonlight
local ml = require("moonlight")

-- build the world as nested tables
ml.world = {
	-- our first room. all rooms must live on the root of the world table.
	{
		-- the room name is also used to reference in the room exits
		name = "West of House",
		-- the words displayed when looking
		description = "You are standing in an open field west of a white house, with a boarded front door.",
		-- possible exits from this room
		exits = {

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
	}
}

-- set simulator options:
-- list contents of containers when opened.
ml.options.autoListContentsOfOpened = true

-- set the player
ml:setPlayer ("You")

-- print a welcome message
io.write("Welcome to your world. Enter 'q' or 'quit' when done exploring.\n\n")

-- let the first turn be a look around the room
--ml:turn("look")

-- begin the game
while true do

	io.write("> ")
	local input = io.read()

	if input == "q" or input == "quit" then
		break
	end

	-- simulate the world
	ml:turn (input)

	-- print all the responses
	for _, message in ipairs(ml.responses) do
		io.write(message, "\n")
	end

	io.write("\n")

end
