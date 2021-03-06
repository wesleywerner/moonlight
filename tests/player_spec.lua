describe ("player", function()

	local function makeWorld ()
		return {
			{
				name = "The Cave",
				description = "A dank and musty old place.",
				contains = {
					{ name = "Alice" },
					{ name = "glowing rock" },
					{ name = "stalagtite" },
				}
			},
			{
				name = "A forest path",
				description = "A bright and lively path.",
				contains = {
					{ name = "Bob" },
					{ name = "hummingbird" },
					{ name = "daisies", article="some" },
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("is alice", function()
		ml:load_world (makeWorld())
		ml:set_player ("Alice")
		ml:turn("look")
		local expected = { "A dank and musty old place. There is a glowing rock and a stalagtite here."}
		assert.are.same(expected, ml.output)
	end)

	it("is bob", function()
		ml:load_world (makeWorld())
		ml:set_player ("Bob")
		ml:turn("look")
		local expected = { "A bright and lively path. There is a hummingbird and some daisies here."}
		assert.are.same(expected, ml.output)
	end)

	it("switches players", function()
		ml:load_world (makeWorld())
		ml:set_player ("Alice")
		ml:turn("look")
		local expected = { "A dank and musty old place. There is a glowing rock and a stalagtite here."}
		assert.are.same(expected, ml.output)

		ml:set_player ("Bob")
		ml:turn("look")
		local expected = { "A bright and lively path. There is a hummingbird and some daisies here."}
		assert.are.same(expected, ml.output)
	end)

end)
