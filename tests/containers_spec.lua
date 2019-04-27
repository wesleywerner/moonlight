describe ("containers", function()

	local function makeWorld ()
		return {
			{
				name = "Bathroom",
				description = "You stand in a bathroom.",
				contains = {
					{
						name = "Alice",
						person = true,
						contains = { {name = "valve"} }
					},
					{
						name = "toilet",
						closed = true,
						contains = {{ name = "gold coin" }}
					},
					{
						name = "black box",
						contains = { },
						closed = false
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
		assert.are.same(expected, ml.output)
	end)

	it("insert to something not seen", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put valve inside the lunchbox")
		local expected = {"I don't see the lunchbox."}
		assert.are.same(expected, ml.output)
	end)

	it("insert response", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("take coin")
		local cmd = ml:turn("put valve inside the box")
		assert.are.equals("in", cmd.direction)
		local expected = {"You put the valve in the black box."}
		assert.are.same(expected, ml.output)
	end)

	it("insert all into open", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("take daisies")
		local cmd = ml:turn("put all inside the box")
		assert.are.equals("in", cmd.direction)
		local expected = {"You put the valve in the black box.", "You put the daisies in the black box."}
		assert.are.same(expected, ml.output)
	end)

	it("insert all into closed", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("take daisies")
		ml:turn("close the black box")
		local cmd = ml:turn("put all inside the box")
		assert.are.equals("in", cmd.direction)
		local expected = {"You can't put things in the black box, it is closed."}
		assert.are.same(expected, ml.output)
	end)

	it("insert into a non-container", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("put valve inside the daisies")
		local expected = {"You can't put things in some daisies."}
		assert.are.same(expected, ml.output)
	end)

	it("insert into a closed container", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("close the black box")
		ml:turn("put valve inside the black box")
		local expected = {"You can't put things in the black box, it is closed."}
		assert.are.same(expected, ml.output)
	end)

	it("insert removes from inventory", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		local cmd = ml:turn("put coin inside the box")
		local carrying = ml:isCarrying("gold coin")
		assert.is_nil(carrying)
	end)

	it("open it", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		local cmd = ml:turn("open the toilet")
		local expected = {"You open the toilet.", "Inside it is a gold coin."}
		assert.are.same(expected, ml.output)
		assert.is.falsy(cmd.first_item.closed)
	end)

	it("open it (with auto listing of contents)", function()
		ml:setWorld (makeWorld())
		ml.options.auto["list contents of opened"] = true
		ml:setPlayer ("Alice")
		local cmd = ml:turn("open the toilet")
		local expected = {"You open the toilet.", "Inside it is a gold coin."}
		assert.are.same(expected, ml.output)
		assert.is.falsy(cmd.first_item.closed)
	end)

	it("close it", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		local cmd = ml:turn("close the toilet")
		local expected = {"You close the toilet."}
		assert.are.same(expected, ml.output)
		assert.is.truthy(cmd.first_item.closed)
	end)

	it("open when already open", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		ml:turn("open the toilet")
		local expected = {"The toilet is already open."}
		assert.are.same(expected, ml.output)
	end)

	it("close when already closed", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("close the toilet")
		local expected = {"The toilet is already closed."}
		assert.are.same(expected, ml.output)
	end)

	it("examine thing inside closed", function()
		local expected = {"I don't see the gold coin."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("examine gold coin")
		assert.are.same(expected, ml.output)
	end)

	it("take thing inside closed", function()
		local expected = {"I don't see the gold coin."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("take the gold coin from toilet")
		assert.are.same(expected, ml.output)
	end)

	it("take all inside closed", function()
		local expected = {"The toilet is closed."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("take all from toilet")
		assert.are.same(expected, ml.output)
	end)

	it("examine open", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("open the toilet")
		ml:turn("examine the toilet")
		local expected = {"It is a toilet. Inside it is a gold coin."}
		assert.are.same(expected, ml.output)
	end)

	it("examine closed", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("examine toilet")
		local expected = {"It is a toilet. It is closed."}
		assert.are.same(expected, ml.output)
	end)

end)

