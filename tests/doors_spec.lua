describe ("open doors", function()

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
						destination = "Kitchen",
					}
				}
			},
			{
				name = "Kitchen",
				description = "You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food.",
				contains = { }
			},
			{
				name = "With compass door",
				description = "A red door is to the east.",
				exits = {
					east = "red door"
				},
				contains = {
					{ name = "Mary", person = true },
					{
						name = "red door",
						destination = "Kitchen",
					}
				}
			},
			{
				name = "With no direction door",
				description = "A red door is to the east.",
				exits = {

				},
				contains = {
					{ name = "Joe", person = true },
					{
						name = "red door",
						destination = "Kitchen",
					},
					{ name = "fake door" }
				}
			}

		}
	end

	it("with direction, via direction", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml.world = makeWorld()
		ml:setPlayer ("Mary")
		ml:turn ("go east")
		assert.are.same(expected, ml.responses)
	end)

	it("with direction, via name", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml.world = makeWorld()
		ml:setPlayer ("Mary")
		ml:turn ("go in the red door")
		assert.are.same(expected, ml.responses)
	end)

	it("without direction, via direction", function()
		local expected = {"You cannot go that way."}
		ml.world = makeWorld()
		ml:setPlayer ("Joe")
		ml:turn ("go east")
		assert.are.same(expected, ml.responses)
	end)

	it("without direction, via name", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml.world = makeWorld()
		ml:setPlayer ("Joe")
		ml:turn ("go the red door")
		assert.are.same(expected, ml.responses)
	end)

	it("via the wrong thing", function()
		local expected = {"You cannot go that way."}
		ml.world = makeWorld()
		ml:setPlayer ("Joe")
		ml:turn ("go in the fake door")
		assert.are.same(expected, ml.responses)
	end)

end)

describe ("closed doors", function()

	pending("implicitly tries to open a door", function()
		local expected = {"You open the front door.", "You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
	end)

end)

describe ("locked doors", function()

	pending("implicitly opening a locked door", function()
		local expected = "TODO"
	end)

end)
