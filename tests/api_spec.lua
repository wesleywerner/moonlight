describe ("search", function()

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
		ml:load_world (makeWorld ())
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
		ml:load_world (makeWorld ())
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
		ml:load_world (makeWorld ())
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
		ml:load_world (makeWorld ())
		local room = ml.world[1]
		local output = ml:search ("shrunken head", room)

		-- search has no result
		assert.is.falsy (output)
	end)

	it ("in a dark room", function()
		ml:load_world (makeWorld ())
		local room = ml.world[1]
		room.is_dark = true
		local output = ml:search ("stone altar", room)

		-- search has no result
		assert.is.falsy (output)
	end)

	it ("as wizard", function()
		ml:load_world (makeWorld ())
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
		ml:load_world (makeWorld ())
		-- search thing in a different room
		local room = ml.world[2]
		local output = ml:search ("stone altar", room)

		-- search has no result
		assert.is.falsy (output)
	end)

	it ("includes rooms", function()
		ml:load_world (makeWorld ())
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

describe ("articles", function()

	local function makeWorld ()
		return {
			{
				name = "Space Station",
				contains = {
					{
						name = "Freddie",
						person = true,
						article = "Captain"
					},
					{
						name = "Bob",
						person = true
					}
				}
			}
		}
	end

	local ml = require("moonlight")

	it ("on a person", function()
		local expectedResponse = {"It is a Space Station. There is Captain Freddie here."}
		ml:load_world (makeWorld ())
		ml:set_player ("Bob")
		ml:turn ("look")
		assert.are.same (expectedResponse, ml.output)
	end)

end)
