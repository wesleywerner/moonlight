describe ("inventory", function ()

	local function makeWorld ()
		return {
			{
				name = "open field",
				contains  = {
					{
						name = "You",
						player = true,
						contains = { }
					},
					{
						name = "coin",
						description = "The stained face of a gold lion looks up at you."
					},
					{
						name = "shovel",
						description = "It looks more like a spade."
					}
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("listing when empty", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("inventory")
		local expected = "You are carrying nothing."
		assert.are.same({expected}, ml.responses)
	end)

	it("listing when holding one thing", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("take the coin")
		ml:turn("inventory")
		local expected = "You are carrying a coin."
		assert.are.same({expected}, ml.responses)
	end)

	it("listing when holding more things", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("take the coin")
		ml:turn("take the shovel")
		ml:turn("inventory")
		local expected = "You are carrying a coin and a shovel."
		assert.are.same({expected}, ml.responses)
	end)

end)
