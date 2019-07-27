describe ("options", function()

	local function makeWorld ()
		return {
			{
				name = "The Cave",
				description = "A dank and musty old place.",
				contains = {
					{ name = "Alice", person = true },
					{ name = "glowing rock" },
					{ name = "stalagtite" },
				}
			},
			{
				name = "A forest path",
				description = "A bright and lively path. A cave entrance lies to the north.",
				contains = {
					{ name = "Bob", person = true },
					{ name = "hummingbird" },
					{ name = "daisies", article="some" },
				},
				exits = {
					north = "The Cave",
					west = "Nowhere",
					east = "Nowhere"
				}
			},
			{
				name = "Tower Stairwell",
				description = "A tight winding white flaked wooden staircase.",
				contains = {
					{ name = "Hugo", person = true },
					{ name = "ladder", destination = "The Bell Tower" },
					{ name = "oak door", closed = true, destination = "The Bell Tower" }
				},
				exits = {
					up = "ladder",
					south = "oak door"
				}
			},
			{
				name = "The Bell Tower",
				description = "High up next to the old bell.",
				exits = {
					down = "Tower Stairwell"
				}
			},
			{
				name = "The Kitchen",
				contains = {
					{ name = "Martha", person = true },
					{
						name = "cupboard",
						closed = true,
						contains = {
							{ name = "pasta", article = "some" },
							{ name = "rice", article = "some" }
						}
					}
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("brief room descriptions", function()
		ml.options.verbose.roomDescriptions = false
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		-- first look gives full description
		ml:turn ("look")
		-- leaving the room, entering again
		ml:turn ("go up")
		ml:turn ("go down")
		assert.are.same ({"There is a ladder and an oak door here. You can go south and up."}, ml.output)
	end)

	it("brief empty room descriptions", function()
		ml.options.verbose.descriptions = false
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		ml:turn ("go up")
		ml:turn ("go down")
		ml:turn ("go up")
		assert.are.same ({"You can go down."}, ml.output)
	end)

	it("verbose room descriptions", function()
		ml.options.verbose.descriptions = true
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		-- first look gives full description
		ml:turn ("look")
		-- leaving the room, entering again
		ml:turn ("go up")
		ml:turn ("go down")
		assert.are.same ({"A tight winding white flaked wooden staircase. There is a ladder and an oak door here. You can go south and up."}, ml.output)
	end)

	it("list exits in lit rooms", function()
		ml:load_world (makeWorld())
		ml.options.flags["list exits"] = true
		ml:set_player ("Bob")
		ml:turn("look")
		local expected = {"A bright and lively path. A cave entrance lies to the north. There is a hummingbird and some daisies here. You can go east, north and west."}
		assert.are.same(expected, ml.output)
	end)

	it("list exits in dark rooms", function()
		ml:load_world (makeWorld())
		ml:room_by_name ("A forest path").dark = true
		ml.options.flags["list exits"] = true
		ml:set_player ("Bob")
		ml:turn("look")
		local expected = {"You are in the dark. You can go east, north and west."}
		assert.are.same(expected, ml.output)
	end)

	it("list contents of opened container", function()
		ml.options.flags["list contents of opened"] = true
		ml:load_world (makeWorld())
		ml:set_player ("Martha")
		ml:turn("open the cupboard")
		local expected = {"You open the cupboard.", "Inside it is some pasta and some rice."}
		assert.are.same(expected, ml.output)
	end)

	it("not list contents of opened container", function()
		ml.options.flags["list contents of opened"] = false
		ml:load_world (makeWorld())
		ml:set_player ("Martha")
		ml:turn("open the cupboard")
		local expected = {"You open the cupboard."}
		assert.are.same(expected, ml.output)
	end)


end)
