describe ("supporters", function()

	local function makeWorld ()
		return {
			{
				name = "A forest path",
				description = "A bright and lively path. A cave entrance lies to the north.",
				contains = {
					{ name = "Alice", person = true, contains = {{ name = "gold coin" }} },
					{ name = "table", supports = { } },
					{ name = "daisies", article="some" },
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("put bad command", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin on the lunchbox")
		local expected = {"You need to tell me where you want to insert the gold coin."}
		assert.are.same(expected, ml.responses)
	end)

	it("put response", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin on the table")
		assert.is_nil(cmd.direction)
		local expected = {"You put the gold coin on the table."}
		assert.are.same(expected, ml.responses)
	end)

	it("put negative response", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin on the daisies")
		assert.is_nil(cmd.direction)
		local expected = {"You can't put things on some daisies."}
		assert.are.same(expected, ml.responses)
	end)

	it("put examine", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		ml:turn("put coin on the table")
		ml:turn("examine the table")
		local expected = {"It is a table. On it is a gold coin."}
		assert.are.same(expected, ml.responses)
	end)

	it("put moves from inventory", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin on the table")
		local carrying = ml:isCarrying("gold coin")
		assert.is_false(carrying)
	end)

end)
