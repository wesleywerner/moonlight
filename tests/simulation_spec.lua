describe("simulation", function()

	local function makeWorld()

		local ego = { }
		ego.name = "You"
		ego.description = "As good looking as ever."
		ego.player = true

		local sucker = { }
		sucker.name = "sucker"
		sucker.description = "a cherry sucker"
		sucker.edible = true

		local bowl = { }
		bowl.name = "bowl"
		bowl.description = "An opaque blue bowl."
		-- any item with a "contains" table is a container
		bowl.contains = { sucker }
		-- in future allow setting how much it can hold
		bowl.space = 1
		sucker.size = 0.1

		local podium = { }
		podium.name = "podium"
		podium.description = "A short podium supporting a bowl."
		-- item is a supporter
		podium.supports = { bowl }

		local lobby = { }
		lobby.name = "Lobby"
		lobby.description = "You are in the hotel lobby."
		lobby.contains = { podium, ego }

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
		local expected = "You are in the hotel lobby. Inside it is a podium."
		assert.are.equals(expected, ml.responses[1])
	end)

	pending("should not list yourself in the room", function()

	end)

	pending("examines the podium", function()

	end)

	it("examines containers", function()
		ml.world = makeWorld()
		ml:turn("look in the bowl")
		local expected = "An opaque blue bowl. Inside it is a sucker."
		assert.are.equals(expected, ml.responses[1])
	end)

	pending("should not take the podium", function()

	end)

	pending("", function()

	end)


end)
