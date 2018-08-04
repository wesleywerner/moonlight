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
		ml:setWorld (makeWorld())
		ml:setPlayer ("Mary")
		ml:turn ("go east")
		assert.are.same(expected, ml.output)
	end)

	it("with direction, via name", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Mary")
		ml:turn ("go in the red door")
		assert.are.same(expected, ml.output)
	end)

	it("without direction, via direction", function()
		local expected = {"You cannot go that way."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Joe")
		ml:turn ("go east")
		assert.are.same(expected, ml.output)
	end)

	it("without direction, via name", function()
		local expected = {"You are in the kitchen of the white house. A table seems to have been used recently for the preparation of food."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Joe")
		ml:turn ("go the red door")
		assert.are.same(expected, ml.output)
	end)

	it("via the wrong thing", function()
		local expected = {"You cannot go that way."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Joe")
		ml:turn ("go in the fake door")
		assert.are.same(expected, ml.output)
	end)

end)

describe ("closed doors", function()

	-- load moonlight
	local ml = require("moonlight")

	-- build the world as nested tables
	function makeWorld()
		return {
			{
				name = "Basement",
				contains = {
					{ name = "Freddie", person = true },
					{
						name = "rotting door",
						closed = true,
						destination = "pantry"
					}
				},
				exits = {
					out = "rotting door"
				}
			},
			{
				name = "Pantry",
				description = "A food pantry for rats."
			}
		}
	end

	it("can't go through", function()
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		ml:turn ("go in the rotting door")
		local expected = {"The door is closed."}
		assert.are.same (expected, ml.output)
	end)

end)

describe ("locked doors", function()

	-- load moonlight
	local ml = require("moonlight")

	-- build the world as nested tables
	function makeWorld()
		return {
			{
				name = "Basement",
				contains = {
					{
						name = "Freddie",
						person = true,
						contains = {
							{
								name = "brass key",
								unlocks = { "rotting door" }
							},
							{ name = "iron key" }
						}
					},
					{
						name = "rotting door",
						closed = true,
						locked = true,
						destination = "pantry"
					}
				},
				exits = {
					out = "rotting door"
				}
			},
			{
				name = "Pantry",
				description = "A food pantry for rats."
			}
		}
	end

	it("requires a door", function()
		local expected = {ml.template.unlock["needs door"]}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		ml:turn ("unlock")
		assert.are.same (expected, ml.output)
	end)

	it("requires a key", function()
		local expected = {ml.template.unlock["needs key"]}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		ml:turn ("unlock the door")
		assert.are.same (expected, ml.output)
	end)

	it("requires a key in hand", function()
		local expected = {string.format(ml.template.thing["not carried"], "brass key")}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		ml:turn ("drop brass key")
		local cmd = ml:turn ("unlock the door with the brass key")
		assert.are.same (expected, ml.output)
	end)

	it("won't unlock with the wrong key", function()
		local expected = {"It won't unlock."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		ml:turn ("unlock the door with the iron key")
		assert.are.same (expected, ml.output)
	end)

	it("will unlock with the right key", function()
		local expected = {"You unlock the rotting door with the brass key."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Freddie")
		local cmd = ml:turn ("unlock the door with the brass key")

		assert.are.same (expected, ml.output)
		assert.is_false (cmd.item1.locked)
	end)

end)
