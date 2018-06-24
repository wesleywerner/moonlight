describe("take", function()

	local function makeWorld()
		return {
			{
				name = "Lobby",
				description = "You are in the hotel lobby.",
				contains = {
					{ name = "You", person = true },
					{ name = "Mary", person = true },
					{
						name = "podium",
						fixed = true,
						description = "A short podium supporting a bowl.",
						supports = {
							{
								name = "bowl",
								description = "An opaque blue bowl.",
								contains = {
									{
										name = "mint"
									}
								}
							}
						}
					},
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

	it("moves the item to inventory", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.same({expected}, ml.responses)

		-- check the mint is in inventory
		local inventory = ml.player.contains
		assert.are.equals("table", type(inventory))
		assert.are.equals(1, #inventory)
		assert.are.equals("mint", inventory[1].name)
	end)

	it("removes the item", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("get mint")
		-- check the mint is not in the bowl
		local bowl = ml.api.searchGlobal(ml, "bowl")
		assert.is.truthy(bowl)
		local mint = bowl.contains[1]
		assert.is.falsy(mint)
	end)

	it("the same thing twice", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.equals(expected, ml.responses[1])
		ml:turn("get mint")
		local expected = "You already have it."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("something fixed in place", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("take the podium")
		local expected = "The podium is fixed in place."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("what you cannot see", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("take the headlamp")
		local expected = "I don't see the headlamp."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("unspecified thing", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("take")
		local expected = "Be a little more specific what you want to take."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("a person", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("take mary")
		local expected = "Mary wouldn't like that."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("all the things in the room", function()
		local expected = {"Mary wouldn't like that.","The podium is fixed in place."}
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("take all")
		assert.are.same(expected, ml.responses)
	end)

	it("all the things from something", function()
		local expected = {"You take the mint."}
		ml.world = makeWorld()
		ml:setPlayer("You")
		local cmd = ml:turn("take all from the bowl")
		assert.is.equals("all", cmd.nouns[1])
		assert.is.equals("bowl", cmd.nouns[2])
		assert.are.same(expected, ml.responses)
	end)

end)
