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
					n = "The Cave"
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("specific direction", function()
		ml.world = makeWorld()
		ml:setPlayer ("Bob")
		ml:turn("go north")
		local expected = {"A dank and musty old place. There is Alice, a glowing rock and a stalagtite here."}
		assert.are.same(expected, ml.responses)
	end)

	it("bad direction", function()
		ml.world = makeWorld()
		ml:setPlayer ("Bob")
		ml:turn("go south")
		local expected = {"You cannot go that way."}
		assert.are.same(expected, ml.responses)
	end)


end)
