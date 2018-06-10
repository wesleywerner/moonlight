describe("simulation", function()

	local function makeWorld()

		local ego = { }
		ego.name = "You"
		ego.description = "As good looking as ever"
		ego.player = true

		local sucker = { }
		sucker.name = "sucker"
		sucker.description = "a cherry sucker"
		sucker.edible = true

		local bowl = { }
		bowl.name = "bowl"
		bowl.description = "It is a bowl full of sweets"
		-- any item with a "contains" table is a container
		bowl.contains = { sucker }
		-- in future allow setting how much it can hold
		bowl.space = 1
		sucker.size = 0.1

		local podium = { }
		podium.name = "podium"
		podium.desc = "A short podium supporting a bowl"
		-- item is a supporter
		podium.supports = { bowl }

		local lobby = { }
		lobby.name = "Lobby"
		lobby.description = "You are in the hotel lobby"
		lobby.contains = { podium, ego }

		return {
			["lobby"] = lobby
		}

	end

	local ml = require("src/moonlight")


	pending("adds to the turn counter", function()

	end)

	it("examines the room", function()

		ml.world = makeWorld()
		ml:turn("look")
		local expected = "You are in the hotel lobby"
		assert.are.equals(expected, ml.responses[1])

	end)

	pending("should not list yourself in the room", function()

	end)

	pending("examines the podium", function()

	end)

	pending("examines the bowl", function()

	end)

	pending("should not take the podium", function()

	end)

	pending("", function()

	end)


end)
