describe ("drop", function ()

	local function makeWorld ()
		return {
			{
				name = "open field",
				contains  = {
					{
						name = "You",
						player = true,
						contains = {
							{
								name = "coin",
								description = "The stained face of a gold lion looks up at you."
							}
						}
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

	it("when holding the item", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("drop the coin")
		local expected = "You drop the coin."
		assert.are.same({expected}, ml.responses)
		local playerHas = ml.api.playerHas (ml, "coin")
		assert.is_false(playerHas)
	end)

	it("when not holding the item", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("drop the coin")
		ml:turn("drop the coin")
		local expected = "You don't have the coin."
		assert.are.same({expected}, ml.responses)
		local playerHas = ml.api.playerHas (ml, "coin")
		assert.is_false(playerHas)
	end)

end)
