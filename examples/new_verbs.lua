--- Adding new verbs example with Moonlight.
-- This example demonstrates how to add a new "fire" verb
-- that allows the player to "fire the weapon at the target".
--
-- When adding weapons to our world give the weapon an "ammo" amount.
-- If a thing has ammunition then we can shoot it. The ammunition decreases with
-- each shot until emptied.
--
-- Creating a "reload" verb is left as an exercise for the coder.
--
-- Browse the @{moonlight} api to learn all about this game.
--
-- Example transcript:
-- You are on a shooting range. You are near a table with weapons on it. The range has various shooting targets -- in it.
--
-- Gun Range > x table
-- It is a table. On it is a pistol, a rifle, a pea shooter and a banana.
--
-- Gun Range > take pistol from table
-- You take the pistol.
--
-- Gun Range > fire pistol at target
-- Bang! You fired the pistol at the target.
--
-- Gun Range > fire pistol at can
-- Bang! You fired the pistol at the can.
--
-- Gun Range > fire pistol at glass jar
-- The glass jar shatters into a thousand pieces.
--
-- Gun Range > fire pistol
-- Click. It is empty.
--
-- Gun Range > x pistol
-- It is a pistol.
-- It is out of ammo.
--
-- Gun Range > take banana
-- You take the banana.
-- 
-- Gun Range > fire banana
-- That is not a weapon.


-- Add moonlight to the package path.
package.path = package.path .. ";./moonlight/?.lua"

-- Load moonlight
local ml = require("moonlight")

-- Load the world model first.
-- This is important because loading of the world also reloads the standard rulebooks.
-- Any rulebook modifications made prior to this point will be lost.
ml:load_world ({
	{
		name = "Gun Range",
		description = "You are on a shooting range.",
		contains = {
			{
				name = "Freddie",
				person = true,
				description = "Good looking as ever."
			},
			{
				name = "table",
				appearance = "You are near a table with weapons on it.",
				fixed = true,
				-- add some weapons, denoted as such by their ammo number
				supports = {
					{
						name = "pistol",
						ammo = 3
					},
					{
						name = "rifle",
						ammo = 3
					},
					{
						name = "pea shooter",
						ammo = 12
					},
					{
						name = "banana"
					}
				}
			},
			{
				name = "range",
				description = "This is the shooting range.",
				appearance = "The range has various shooting targets in it.",
				fixed = "As much as you try, you can't fit the world in your pocket.",
				-- Add targets in the range. It acts like a container and we overwrite
				-- the fixed property to prevent the player from picking these up.
				contains = {
					{
						name = "target",
						description = "It is a gun target that comprises a four concentric circles.",
						fixed = "The target is happy on the range."
					},
					{
						name = "can",
						description = "It is a can of baked beans.",
						fixed = "Best leave the can where it is."
					},
					{
						name = "glass jar",
						description = "It is an empty glass jar.",
						fixed = "I'm not picking that up!"
					}
				}
			}

		}
	}

})

-- Add an examine rule that will print out the amount of ammo a thing has.
table.insert(ml.rulebooks.after.examine, {
	name = "report ammo of a thing",
	action = function(moonlight, command)
		-- alias for ease of readibility
		local thing = command.first_item
		-- test the thing is real
		if not thing then return end
		-- this thing has ammo
		if type(thing.ammo) == "number" then
			if thing.ammo == 0 then
				return "It is out of ammo."
			elseif thing.ammo == 1 then
				return "It has one round left."
			else
				return "It has " .. tostring(thing.ammo) .. " rounds remaining."
			end
		end
	end
	})

-- Create the "fire" before/on/after rulebooks
ml.rulebooks.before["fire"] = { }
ml.rulebooks.on["fire"] = { }
ml.rulebooks.after["fire"] = { }

-- Create a before fire rule that ensures the thing that is being
-- fired is in fact a weapon, that it has ammo, and that the player
-- is carrying it, and that the player has named target.
-- If any test fails we return a helpful message and false to signal
-- stopping further processing of this action.
table.insert(ml.rulebooks.before.fire, {
	name = "a thing can be fired",
	action = function(moonlight, command)
		-- alias for ease of readibility
		local thing = command.first_item
		-- Test the thing is real.
		if not thing then
			return "You must tell me what to fire.", false
		end
		-- Test the thing has ammo
		if type(thing.ammo) ~= "number" then
			return "That is not a weapon.", false
		end
		if thing.ammo == 0 then
			return "Click. It is empty.", false
		end
		-- Test the player is carrying the weapon
		if not moonlight:is_carrying(thing) then
			return "You need to carry it to fire it.", false
		end
		-- Test the player has named a target to fire at
		if not command.second_item then
			return "You need to tell me what to fire at.", false
		end
	end
	})

-- Next create the "on" fire rule which occurs after the before rule succeeds.
-- It decreases the ammo count and adds some flavor text.
table.insert(ml.rulebooks.on.fire, {
	name = "firing a weapon",
	action = function(moonlight, command)
		-- alias
		local weapon = command.first_item
		local target = command.second_item
		-- reduce ammo
		weapon.ammo = weapon.ammo - 1
		-- the glass jar will shatter and be removed from play
		if target.name == "glass jar" then
			moonlight:detach(target)
			return "The glass jar shatters into a thousand pieces."
		else
			return "Bang! You fired the " .. weapon.name .. " at the " .. target.name .. "."
		end

	end
	})

-- Set the player character by name
ml:set_player ("Freddie")

-- Print a welcome message
io.write("\nWelcome. You can LOOK AT things, TAKE things (take all from table), and FIRE WEAPON AT TARGET. BYE or EXIT ends the game.\n\n")

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
