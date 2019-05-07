describe("take", function()

	local function makeWorld()
		return {
			{
				name = "Lobby",
				description = "You are in the hotel lobby.",
				contains = {
					{ name = "You", person = true },
					{ name = "Mary", person = true,
						contains = {
							{ name = "topaz ring" }
						}
					},
					{
						name = "podium",
						fixed = true,
						description = "A short podium supporting a bowl.",
						supports = {
							{
								name = "bowl",
								description = "An opaque blue bowl.",
								fixed = "You have no need for the bowl.",
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
			},
			{
				name = "Secret Alcove",
				contains = {
					{
						name = "Carrie",
						person = true
					},
					{ name = "red key" },
					{ name = "blue key" }
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("moves the item to inventory", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.same({expected}, ml.output)

		-- check the mint is in inventory
		local inventory = ml.player.contains
		assert.are.equals("table", type(inventory))
		assert.are.equals(1, #inventory)
		assert.are.equals("mint", inventory[1].name)
	end)

	it("removes the item", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("get mint")
		-- check the mint is not in the bowl
		local match = ml:search ("bowl")
		local bowl = unpack(match[1])
		assert.is.truthy(bowl)
		local mint = bowl.contains[1]
		assert.is.falsy(mint)
	end)

	it("the same thing twice", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.equals(expected, ml.output[1])
		ml:turn("get mint")
		local expected = "You already have it."
		assert.are.equals(expected, ml.output[1])
	end)

	it("something fixed in place", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take the podium")
		local expected = "The podium is fixed in place."
		assert.are.equals(expected, ml.output[1])
	end)

	it("something fixed in place with custom message", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take the bowl")
		local expected = "You have no need for the bowl."
		assert.are.equals(expected, ml.output[1])
	end)

	it("what you cannot see", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take the headlamp")
		local expected = "I don't see the headlamp."
		assert.are.equals(expected, ml.output[1])
	end)

	it("unspecified thing", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take")
		local expected = "Be a little more specific what you want to take."
		assert.are.equals(expected, ml.output[1])
	end)

	it("missing noun", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take the grue")
		local expected = "I don't see the grue."
		assert.are.equals(expected, ml.output[1])
	end)

	it("a person", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take mary")
		local expected = "Mary wouldn't like that."
		assert.are.equals(expected, ml.output[1])
	end)

	it("thing carried by another person", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take the topaz ring")
		local expected = {"I don't see the topaz ring."}
		assert.are.same(expected, ml.output)
	end)

	it("all the things in the room", function()
		local expected = {"Mary wouldn't like that.","The podium is fixed in place."}
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("take all")
		assert.are.same(expected, ml.output)
	end)

	it("all the things from something", function()
		local expected = {"You take the mint."}
		ml:load_world (makeWorld())
		ml:set_player("You")
		local cmd = ml:turn("take all from the bowl")
		assert.is.equals("all", cmd.nouns[1])
		assert.is.equals("bowl", cmd.nouns[2])
		assert.are.same(expected, ml.output)
	end)

end)
