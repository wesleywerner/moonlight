describe("simulation", function()

	local function makeWorld()

		local ego = { }
		ego.name = "You"
		ego.description = "As good looking as ever."
		ego.contains = { }
		ego.player = true

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
		-- any item with a "contains" table is a container
		bowl.contains = { mint }
		-- in future allow setting how much it can hold
		bowl.space = 1
		mint.size = 0.1

		local podium = { }
		podium.name = "podium"
		podium.description = "A short podium supporting a bowl."
		podium.fixed = true
		-- item is a supporter
		podium.supports = { bowl }

		local envelope = { }
		envelope.name = "envelope"

		local key = { }
		key.name = "key"

		local bookcase = { }
		bookcase.name = "bookcase"
		bookcase.contains = { envelope }
		bookcase.supports = { key }

		local lobby = { }
		lobby.name = "Lobby"
		lobby.description = "You are in the hotel lobby."
		lobby.contains = { bookcase, podium, ego, mary }

		return {
			["lobby"] = lobby
		}

	end

	local ml = require("src/moonlight")

	it("adds to the turn number on valid commands", function()
		ml.world = makeWorld()
		local tn = ml.turnNumber
		ml:turn("look")
		assert.are.equals(tn+1, ml.turnNumber)
	end)

	it("does not add to the turn number on invalid commands", function()
		ml.world = makeWorld()
		local tn = ml.turnNumber
		ml:turn("snafu foobar")
		assert.are.equals(tn, ml.turnNumber)
	end)

	it("examines the room", function()
		ml.world = makeWorld()
		ml:turn("look")
		local expected = "You are in the hotel lobby. There is a bookcase, a podium and Mary here."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("examines containers", function()
		ml.world = makeWorld()
		ml:turn("look in the bowl")
		local expected = "An opaque blue bowl. Inside it is a mint."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("examine supporters", function()
		ml.world = makeWorld()
		ml:turn("x podium")
		local expected = "A short podium supporting a bowl. On it is a bowl."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("examine supporting containers", function()
		ml.world = makeWorld()
		ml:turn("examine bookcase")
		local expected = "It is a bookcase. Inside it is an envelope. On it is a key."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("take something moves it into inventory", function()
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

	it("take something removes it from position", function()
		ml.world = makeWorld()
		ml:turn("get mint")
		-- check the mint is not in the bowl
		local bowl = ml.api.search(ml, "bowl", ml.world["lobby"])
		assert.is.truthy(bowl)
		local mint = bowl.contains[1]
		assert.is.falsy(mint)
	end)

	it("cannot take the same thing twice", function()
		ml.world = makeWorld()
		ml:turn("get mint")
		local expected = "You take the mint."
		assert.are.equals(expected, ml.responses[1])
		ml:turn("get mint")
		local expected = "You already have it."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("cannot take something fixed in place", function()
		ml.world = makeWorld()
		ml:turn("take the podium")
		local expected = "The podium is fixed in place."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("cannot take what you cannot see", function()
		ml.world = makeWorld()
		ml:turn("take the headlamp")
		local expected = "I don't see the headlamp."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("cannot take unspecified thing", function()
		ml.world = makeWorld()
		ml:turn("take")
		local expected = "Be a little more specific what you want to take."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("cannot take a person", function()
		ml.world = makeWorld()
		ml:turn("take mary")
		local expected = "Mary wouldn't like that."
		assert.are.equals(expected, ml.responses[1])
	end)

	pending("successful actions flag", function()

	end)

	pending("failed actions flag", function()

	end)

	pending("", function()

	end)


end)
