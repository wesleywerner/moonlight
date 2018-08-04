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
		ml:setWorld (makeWorld())
		ml:setPlayer("You")
		ml:turn("drop the coin")
		local expected = "You drop the coin."
		assert.are.same({expected}, ml.output)
		local playerHas = ml:isCarrying ("coin")
		assert.is_nil(playerHas)
	end)

	it("when not holding the item", function()
		ml:setWorld (makeWorld())
		ml:setPlayer("You")
		ml:turn("drop the coin")
		ml:turn("drop the coin")
		local expected = "You don't have the coin."
		assert.are.same({expected}, ml.output)
		local playerHas = ml:isCarrying ("coin")
		assert.is_nil(playerHas)
	end)

	it("unspecified thing", function()
		ml:setWorld (makeWorld())
		ml:setPlayer("You")
		ml:turn("drop the lamp")
		local expected = "I don't see the lamp."
		assert.are.same({expected}, ml.output)
	end)

	it("missing noun", function()
		ml:setWorld (makeWorld())
		ml:setPlayer("You")
		ml:turn("drop")
		local expected = "Be a little more specific what you want to drop."
		assert.are.same({expected}, ml.output)
	end)

end)
