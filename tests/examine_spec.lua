describe("examine", function()

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
		bookcase.description = "It is just wooden box without the books."
		bookcase.contains = { envelope }
		bookcase.supports = { key }

		local lobby = { }
		lobby.name = "Lobby"
		lobby.description = "You are in the hotel lobby."
		lobby.contains = { bookcase, podium, ego, mary }

		return {
			lobby,
			{
				name = "Empty Space",
				description = "It seems empty.",
				contains = {
					{ name = "Bob", person = true }
				}
			}
		}

	end

	local ml = require("src/moonlight")

	it("the room", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("look")
		local expected = "You are in the hotel lobby. There is a bookcase, a podium and Mary here."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("an empty room", function()
		ml.world = makeWorld()
		ml:setPlayer("Bob")
		ml:turn("look")
		local expected = "It seems empty."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("a container", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("look in the bowl")
		local expected = "An opaque blue bowl. Inside it is a mint."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("a supporter", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("x podium")
		local expected = "A short podium supporting a bowl. On it is a bowl."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("a supporting container", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("examine bookcase")
		local expected = "It is just wooden box without the books. Inside it is an envelope. On it is a key."
		assert.are.equals(expected, ml.responses[1])
	end)

	it("an unknown thing", function()
		ml.world = makeWorld()
		ml:setPlayer("You")
		ml:turn("examine the snargle")
		local expected = "I don't see the snargle."
		assert.are.equals(expected, ml.responses[1])
	end)

end)
