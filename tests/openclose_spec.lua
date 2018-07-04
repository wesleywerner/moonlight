describe ("container", function()

	local function makeWorld ()
		return {
			{
				name = "Bathroom",
				description = "You stand in a bathroom.",
				contains = {
					{ name = "Alice", person = true },
					{
						name = "toilet",
						closed = true,
						contains = {{ name = "gold coin" }}
					}
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("examine closed", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		ml:turn("examine toilet")
		local expected = {"It is a toilet. It is closed."}
		assert.are.same(expected, ml.responses)
	end)

	it("open it", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		local cmd = ml:turn("open the toilet")
		local expected = {"You open the toilet."}
		assert.are.same(expected, ml.responses)
		assert.is.falsy(cmd.item1.closed)
	end)

	it("open it (with auto listing of contents)", function()
		ml.world = makeWorld()
		ml.options.auto["list contents of opened"] = true
		ml:setPlayer ("Alice")
		local cmd = ml:turn("open the toilet")
		local expected = {"You open the toilet.", "Inside it is a gold coin."}
		assert.are.same(expected, ml.responses)
		assert.is.falsy(cmd.item1.closed)
	end)

	it("close it", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		local cmd = ml:turn("close the toilet")
		local expected = {"You close the toilet."}
		assert.are.same(expected, ml.responses)
		assert.is.truthy(cmd.item1.closed)
	end)

	it("open when already open", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		ml:turn("open the toilet")
		local expected = {"The toilet is already open."}
		assert.are.same(expected, ml.responses)
	end)

	it("close when already closed", function()
		ml.world = makeWorld()
		ml:setPlayer ("Alice")
		ml:turn("close the toilet")
		local expected = {"The toilet is already closed."}
		assert.are.same(expected, ml.responses)
	end)


end)
