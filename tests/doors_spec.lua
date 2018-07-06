describe ("doors", function()

	-- load moonlight
	local ml = require("moonlight")

	-- build the world as nested tables
	function makeWorld()
		return {
			{
				name = "West of House",
				description = "You are standing in an open field west of a white house.",
				exits = { },
				contains = {
					{ name = "Bob", person = true },
					{
						name = "front door",
						closed = true,
						destination = "Kitchen"
					}
				}
			},
			{
				name = "Behind House",
				description = "You are behind the white house. Here is a small window which is slightly ajar.",
				exits = { },
				contains = {
					{ name = "Alice", person = true },
					{
						name = "small window",
						closed = true,
						destination = "Kitchen",
					}
				}
			},
			{
				name = "Kitchen",
				description = "You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."
			}
		}
	end

	pending("by direction", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn ("open the front door")
		ml:turn ("go east")
		assert.are.same(expected, ml.responses)
	end)

	pending("implicitly tries to open a door", function()
		local expected = {"You open the front door.", "You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml.world = makeWorld()
		ml:setPlayer ("Bob")
		ml:turn ("go east")
		assert.are.same(expected, ml.responses)
	end)

	pending("by going the thing", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml.world = makeWorld()
		ml:setPlayer ("Bob")
		ml:turn ("open the front door")
		ml:turn ("go the front door")
		assert.are.same(expected, ml.responses)
	end)

	pending("by entering the thing", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml.world = makeWorld()
		ml:setPlayer ("Bob")
		ml:turn ("open the front door")
		ml:turn ("enter the front door")
		assert.are.same(expected, ml.responses)
	end)

	pending("described with direction", function()
		local expected = "You are standing in an open field west of a white house. A front door is to the east."
	end)

	pending("described without direction", function()
		local expected = "You are behind the white house. Here is a small window which is slightly ajar."
	end)

	pending("implicitly opening a locked door", function()
		local expected = "TODO"
		ml.world = makeWorld()
		ml:setPlayer ("Bob")
		ml:turn ("go east")
		assert.are.same(expected, ml.responses)
	end)


end)
