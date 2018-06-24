describe("take", function()

	local function makeWorld()

		local ego = { }
		ego.name = "You"
		ego.description = "As good looking as ever."
		ego.person = true

		local mary = { }
		mary.name = "Mary"
		mary.description = "As good looking as ever."
		mary.contains = { }
		mary.person = true

		local mint = { }
		mint.name = "mint"
		mint.description = "A small round, white peppermint."
		mint.edible = true

		local bowl = { }
		bowl.name = "bowl"
		bowl.description = "An opaque blue bowl."
		bowl.contains = { mint }

		local podium = { }
		podium.name = "podium"
		podium.description = "A short podium supporting a bowl."
		podium.fixed = true
		podium.supports = { bowl }

		local lobby = { }
		lobby.name = "Lobby"
		lobby.description = "You are in the hotel lobby."
		lobby.contains = { podium, ego, mary }

		return {
			["lobby"] = lobby
		}

	end

	local ml = require("src/moonlight")

	it("moves the item to inventory", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.equals(expected, ml.responses[1])

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
		local bowl = ml.api.search(ml, "bowl", ml.world["lobby"])
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

	pending("all things", function()
	end)

end)
