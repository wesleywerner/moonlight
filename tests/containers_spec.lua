describe ("containers", function()

	local function makeWorld ()
		return {
			{
				name = "A forest path",
				description = "A bright and lively path. A cave entrance lies to the north.",
				contains = {
					{ name = "Alice", person = true, contains = {{ name = "gold coin" }} },
					{ name = "black box", contains = { } },
					{ name = "daisies", article="some" },
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("insert bad command", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin inside the lunchbox")
		local expected = {"You need to tell me where you want to insert the gold coin."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert response", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin inside the box")
		assert.are.equals("in", cmd.direction)
		local expected = {"You put the gold coin in the black box."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert negative response", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		ml:turn("put coin inside the daisies")
		local expected = {"You can't put things in some daisies."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert examine", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		ml:turn("put coin inside the box")
		ml:turn("examine black box")
		local expected = {"It is a black box. Inside it is a gold coin."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert moves from inventory", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin inside the box")
		local carrying = ml:isCarrying("gold coin")
		assert.is_false(carrying)
	end)

end)
