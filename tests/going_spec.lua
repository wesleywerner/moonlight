describe ("going", function()

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
				},
				exits = {
					north = "The Cave",
					west = "Nowhere",
					east = "Nowhere"
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("specific direction", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn("go north")
		local expected = {"A dank and musty old place. There is Alice, a glowing rock and a stalagtite here."}
		assert.are.same(expected, ml.responses)
	end)

	it("invalid direction", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn("go south")
		local expected = {"You cannot go that way."}
		assert.are.same(expected, ml.responses)
	end)

	it("bad direction", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn("go west")
		local expected = {"You cannot go that way."}
		assert.are.same(expected, ml.responses)
	end)

	it("auto describe exits", function()
		ml:setWorld (makeWorld())
		ml.options.auto["describe exits"] = true
		ml:setPlayer ("Bob")
		ml:turn("look")
		local expected = {"A bright and lively path. A cave entrance lies to the north. There is a hummingbird and some daisies here. You can go east, north and west."}
		assert.are.same(expected, ml.responses)
	end)

	it("room without exits", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("go north")
		local expected = {"The room \"The Cave\" does not have exits defined, you can never leave!"}
		assert.are.same(expected, ml.responses)
	end)


end)
