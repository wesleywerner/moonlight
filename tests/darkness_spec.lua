describe ("darkness", function()

	local function makeWorld ()
		return {
			{
				name = "The Cave",
				description = "A dank and musty old place.",
				dark = true,
				contains = {
					{ name = "Bob", person = true, contains = { { name = "gold coin" } } },
					{ name = "stalagmite" },
					{ name = "carton", contains = {}, closed = false }
				},
				exits = { s = "A forest path" }
			},
			{
				name = "A forest path",
				description = "A bright and lively path. A cave entrance lies to the north.",
				contains = {
					{ name = "glowing rock", lit = true },
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

	it("does not describe dark rooms", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn("look")
		local expected = {"You are in the dark. You can go s."}
		assert.are.same(expected, ml.responses)
	end)

	it("does not describe things in dark rooms", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn("examine stalagmite")
		local expected = {"I don't see the stalagmite."}
		assert.are.same(expected, ml.responses)
	end)

	it("does not take things in dark rooms", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn("take the stalagmite")
		local expected = {"I don't see the stalagmite."}
		assert.are.same(expected, ml.responses)
	end)

	it("does not take inventory in dark rooms", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Bob")
		ml:turn("inventory")
		local expected = {"It is too dark to do that."}
		assert.are.same(expected, ml.responses)
	end)

	it("light source in the room", function()
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Bob")
		-- warp the glowing rocks into the cave
		ml:purloin ("glowing rock")
		ml:turn ("drop glowing rock")
		ml:turn ("look")
		assert.are.same ({"A dank and musty old place. There is a stalagmite, a carton and a glowing rock here."}, ml.responses)
	end)

	it("light source in open containers", function()
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Bob")
		-- warp the glowing rocks into the cave
		ml:purloin ("glowing rock")
		ml:turn ("insert glowing rock in the carton")
		ml:turn ("look")
		assert.are.same ({"A dank and musty old place. There is a stalagmite and a carton here."}, ml.responses)
	end)

	it("light source in closed containers", function()
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Bob")
		-- warp the glowing rocks into the cave
		ml:purloin ("glowing rock")
		ml:turn ("insert glowing rock in the carton")
		ml:turn ("close the carton")
		ml:turn ("look")
		assert.are.same ({"You are in the dark. You can go s."}, ml.responses)
	end)

	it("carried light source", function()
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Bob")
		-- warp the glowing rocks into the cave
		ml:purloin ("glowing rock")
		assert.is.truthy (ml:isCarrying ("glowing rock"))
		ml:turn ("look")
		assert.are.same ({"A dank and musty old place. There is a stalagmite and a carton here."}, ml.responses)
	end)


end)
