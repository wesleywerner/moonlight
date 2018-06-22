describe("turn", function()

	local function makeWorld()

		local ego = { }
		ego.name = "You"
		ego.description = "As good looking as ever."
		ego.contains = { }
		ego.player = true

		local bookcase = { }
		bookcase.name = "bookcase"
		bookcase.description = "It is just wooden box without the books."

		local lobby = { }
		lobby.name = "Lobby"
		lobby.description = "You are in the hotel lobby."
		lobby.contains = { bookcase, ego }

		return {
			["lobby"] = lobby
		}

	end

	local ml = require("src/moonlight")

	it("increments the turn number on valid commands", function()
		ml.world = makeWorld()
		local tn = ml.turnNumber
		ml:turn("look")
		assert.are.equals(tn+1, ml.turnNumber)
	end)

	it("does not increment the turn number on invalid commands", function()
		ml.world = makeWorld()
		local tn = ml.turnNumber
		ml:turn("snafu foobar")
		assert.are.equals(tn, ml.turnNumber)
	end)

	it("match partial nouns", function()
		ml.world = makeWorld()
		ml:turn("examine book")
		local expected = "It is just wooden box without the books."
		assert.are.same({expected}, ml.responses)
	end)

	it("counts the times a thing is verbed", function()
		ml.world = makeWorld()
		local command = ml:turn("examine the bookcase")
		assert.are.equal(1, command.item1.count["examine"])
		ml:turn("examine the bookcase")
		command = ml:turn("examine the bookcase")
		assert.are.equal(3, command.item1.count["examine"])
	end)

	it("does not understand unknown verbs", function()
		local result = ml:turn("snafu the lantern")
		assert.are.same({"I don't know what \"snafu\" means."}, ml.responses)
	end)


end)
