describe ("containers", function()

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
					},
					{
						name = "black box",
						contains = { }
					},
					{
						name = "daisies",
						article = "some"
					}
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("insert something not carried", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin inside the box")
		assert.are.equals("in", cmd.direction)
		local expected = {"You don't have the gold coin."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert to something not seen", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin inside the lunchbox")
		local expected = {"You need to tell me where you want to insert the gold coin."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert default response", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("take coin")
		local cmd = ml:turn("put coin inside the box")
		assert.are.equals("in", cmd.direction)
		local expected = {"You put the gold coin in the black box."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert into a non-container", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("take coin")
		ml:turn("put coin inside the daisies")
		local expected = {"You can't put things in some daisies."}
		assert.are.same(expected, ml.responses)
	end)

	it("insert removes from inventory", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin inside the box")
		local carrying = ml:isCarrying("gold coin")
		assert.is_false(carrying)
	end)

	it("open it", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		local cmd = ml:turn("open the toilet")
		local expected = {"You open the toilet."}
		assert.are.same(expected, ml.responses)
		assert.is.falsy(cmd.item1.closed)
	end)

	it("open it (with auto listing of contents)", function()
		ml:setWorld (makeWorld())
		ml.options.auto["list contents of opened"] = true
		ml:setPlayer ("Alice")
		local cmd = ml:turn("open the toilet")
		local expected = {"You open the toilet.", "Inside it is a gold coin."}
		assert.are.same(expected, ml.responses)
		assert.is.falsy(cmd.item1.closed)
	end)

	it("close it", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		local cmd = ml:turn("close the toilet")
		local expected = {"You close the toilet."}
		assert.are.same(expected, ml.responses)
		assert.is.truthy(cmd.item1.closed)
	end)

	it("open when already open", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		ml:turn("open the toilet")
		local expected = {"The toilet is already open."}
		assert.are.same(expected, ml.responses)
	end)

	it("close when already closed", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("close the toilet")
		local expected = {"The toilet is already closed."}
		assert.are.same(expected, ml.responses)
	end)

	pending("examine thing inside closed", function()
		local expected = {""}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("")
		assert.are.same(expected, ml.responses)
	end)

	pending("take thing inside closed", function()
		local expected = {""}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("")
		assert.are.same(expected, ml.responses)
	end)

	pending("", function()
		local expected = {""}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("")
		assert.are.same(expected, ml.responses)
	end)

	pending("", function()
		local expected = {""}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("")
		assert.are.same(expected, ml.responses)
	end)

	pending("", function()
		local expected = {""}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("")
		assert.are.same(expected, ml.responses)
	end)

	it("examine open", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		ml:turn("examine the toilet")
		local expected = {"It is a toilet. Inside it is a gold coin."}
		assert.are.same(expected, ml.responses)
	end)

	it("examine closed", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("examine toilet")
		local expected = {"It is a toilet. It is closed."}
		assert.are.same(expected, ml.responses)
	end)

end)

