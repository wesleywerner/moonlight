describe ("api thingClosedOrDark", function()

	local ml = require("moonlight")

	local function makeWorld ()
		return {
			{
				name = "The Cave",
				description = "A dank and musty old place.",
				contains = {
					{ name = "Alice", person = true },
					{ name = "glowing rock" },
					{ name = "stalagtite" },
				}
			},
			{
				name = "A forest path",
				description = "A bright and lively path. A cave entrance lies to the north.",
				contains = {
					{ name = "Bob", person = true },
					{ name = "hummingbird" },
					{ name = "daisies", article="some" },
				}
			}
		}
	end

	it ("false by default", function()
		local expected = false
		local test = { name = "Forest" }
		local output = ml:thingClosedOrDark (test)
		assert.are.equals(expected, output)
	end)

	it ("false when dark and lit", function()
		local expected = false
		local test = { name = "Forest", dark = true, lit = true }
		local output = ml:thingClosedOrDark (test)
		assert.are.equals(expected, output)
	end)

	it ("true when closed", function()
		local expected = true
		local test = { name = "Chest", closed = true }
		local output = ml:thingClosedOrDark (test)
		assert.are.equals(expected, output)
	end)

	it ("false when open", function()
		local expected = false
		local test = { name = "Chest", closed = false }
		local output = ml:thingClosedOrDark (test)
		assert.are.equals(expected, output)
	end)

	it ("true when dark and lit and closed", function()
		local expected = true
		local test = { name = "Forest", dark = true, lit = true, closed = true }
		local output = ml:thingClosedOrDark (test)
		assert.are.equals(expected, output)
	end)

end)

describe ("api search", function()

	local ml = require("moonlight")

	local function makeWorld ()
		return {
			{
				name = "Mayan Site",
				description = "An isolated clearing overgrown with vines and shrubbery.",
				contains = {
					{
						name = "stone altar",
						supports = {
							{
								name = "wooden casket",
								contains = {
									{
										name = "jeweled box",
										closed = true,
										contains = {
											{
												name = "shrunken head"
											}
										}
									}
								}
							}
						}
					}
				}
			},
			{
				name = "Shallow",
				description = "A dank and musty old place.",
				contains = {
					{ name = "Alice", person = true },
					{ name = "glowing rock" },
					{ name = "stalagtite" },
				}
			},
		}
	end

	it ("by name", function()
		ml:setWorld (makeWorld ())
		local room = ml.world[1]
		local output = ml:search ("stone altar", room)

		-- search has a result
		assert.is.truthy (output)
		-- unpack the result
		local item, parent, index, ctype = unpack (output[1])
		-- item match
		assert.are.equals ("stone altar", item.name)
		-- item parent match
		assert.are.equals (room, parent)
	end)

	it ("by reference", function()
		ml:setWorld (makeWorld ())
		local room = ml.world[1]
		local thing = room.contains[1]
		local output = ml:search (thing, room)

		-- search has a result
		assert.is.truthy (output)
		-- unpack the result
		local item, parent, index, ctype = unpack (output[1])
		-- item match
		assert.are.equals (thing, item)
		-- item parent match
		assert.are.equals (room, parent)
	end)

	it ("by predicate", function()
		ml:setWorld (makeWorld ())
		local room = ml.world[1]
		local function pred (test)
			return test.name == "wooden casket"
		end
		local output = ml:search (pred, room)

		-- search has a result
		assert.is.truthy (output)
		-- unpack the result
		local item, parent, index, ctype = unpack (output[1])
		-- item match
		assert.are.equals ("wooden casket", item.name)
		-- item parent match
		assert.are.equals (room.contains[1], parent)
	end)

	it ("seen things only", function()
		ml:setWorld (makeWorld ())
		local room = ml.world[1]
		local output = ml:search ("shrunken head", room)

		-- search has no result
		assert.is.falsy (output)
	end)

	it ("in a dark room", function()
		ml:setWorld (makeWorld ())
		local room = ml.world[1]
		room.dark = true
		local output = ml:search ("stone altar", room)

		-- search has no result
		assert.is.falsy (output)
	end)

	it ("as wizard", function()
		ml:setWorld (makeWorld ())
		local room = ml.world[1]
		local output = ml:search ("shrunken head", room, true)

		-- search has result
		assert.is.truthy (output)
		-- unpack the result
		local item, parent, index, ctype = unpack (output[1])
		-- item match
		assert.are.equals ("shrunken head", item.name)
	end)

	it ("by limited scope", function()
		ml:setWorld (makeWorld ())
		-- search thing in a different room
		local room = ml.world[2]
		local output = ml:search ("stone altar", room)

		-- search has no result
		assert.is.falsy (output)
	end)

	it ("includes rooms", function()
		ml:setWorld (makeWorld ())
		local room = ml.world[1]
		local output = ml:search ("Mayan Site")

		-- search has a result
		assert.is.truthy (output)
		-- unpack the result
		local item, parent, index, ctype = unpack (output[1])
		-- item match
		assert.are.equals (room, item)

	end)

end)

describe ("move thing", function()

	local function makeWorld ()
		return {
			{
				name = "Space Station",
				contains = {
					{
						name = "Freddie",
						person = true,
						contains = {
							{ name = "screwdriver" },
							{ name = "laser gun" }
						}
					},
					{
						name = "security locker",
						contains = { },
						supports = { }
					}
				}
			}
		}
	end

	local ml = require("moonlight")

	it ("inside something", function()
		local expectedResponse = {"You put the laser gun in the security locker."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		ml:turn ("put the gun in the locker")
		--
		assert.are.same (expectedResponse, ml.output)
	end)

	it ("on top something", function()
		local expectedResponse = {"You put the laser gun on the security locker."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		ml:turn ("put the gun on the locker")
		--
		assert.are.same (expectedResponse, ml.output)
	end)

end)
