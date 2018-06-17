describe("simulation", function()

	local function makeWorld()

		local ego = { }
		ego.name = "You"
		ego.description = "As good looking as ever."
		ego.contains = { }
		ego.player = true

		local mint = { }
		mint.name = "mint"
		mint.description = "A small round, white peppermint."
		mint.edible = true

		local bowl = { }
		bowl.name = "bowl"
		bowl.description = "An opaque blue bowl."
		-- any item with a "contains" table is a container
		bowl.contains = { mint }
		-- in future allow setting how much it can hold
		bowl.space = 1
		mint.size = 0.1

		local podium = { }
		podium.name = "podium"
		podium.description = "A short podium supporting a bowl."
		-- item is a supporter
		podium.contains = { bowl }

		local lobby = { }
		lobby.name = "Lobby"
		lobby.description = "You are in the hotel lobby."
		lobby.contains = { podium, ego }

		return {
			["lobby"] = lobby
		}

	end

	local ml = require("src/moonlight")

	pending("adds to the turn number on valid commands", function()
		ml.world = makeWorld()
		local tn = ml.turnNumber
		ml:turn("look")
		assert.are.equals(tn+1, ml.turnNumber)
	end)

	pending("does not add to the turn number on invalid commands", function()
		ml.world = makeWorld()
		local tn = ml.turnNumber
		ml:turn("snafu foobar")
		assert.are.equals(tn, ml.turnNumber)
	end)

	pending("examines the room", function()
		ml.world = makeWorld()
		ml:turn("look")
		local expected = "You are in the hotel lobby. There is a podium here."
		assert.are.equals(expected, ml.responses[1])
	end)

	pending("examines containers", function()
		ml.world = makeWorld()
		ml:turn("look in the bowl")
		local expected = "An opaque blue bowl. Inside it is a mint."
		assert.are.equals(expected, ml.responses[1])
	end)

	pending("examine supporters", function()
		ml.world = makeWorld()
		ml:turn("x podium")
		local expected = "A short podium supporting a bowl. On it is a bowl."
		assert.are.equals(expected, ml.responses[1])
	end)

	pending("examine supporting containers", function()

	end)

	pending("take something moves it into inventory", function()
		ml.world = makeWorld()
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.equals(expected, ml.responses[1])

		-- check the mint is in inventory
		local inventory = ml.player.contains
		assert.are.equals("table", type(inventory))
		assert.are.equals(1, #inventory)
		assert.are.equals("mint", inventory[1].name)
	end)

	pending("take something removes it from position", function()
		ml.world = makeWorld()
		ml:turn("get mint")
		-- check the mint is not in the bowl
		local bowl = ml.api.findItem(ml, "bowl", ml.world["lobby"])
		assert.is.truthy(bowl)
		local mint = bowl.contains[1]
		assert.is.falsy(mint)
	end)

	it("cannot take the same thing twice", function()
		ml.world = makeWorld()
		print("\tFIRST TAKE")
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.equals(expected, ml.responses[1])

		print("\tSECOND TAKE")
		ml:turn("get mint")

		print("\t* player has " .. tostring(ml.player.contains[1].name))
		local expected = "You already have it."
		assert.are.equals(expected, ml.responses[1])
	end)

	pending("", function()

	end)


end)
