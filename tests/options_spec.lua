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
					{ name = "Alice", person = true },
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
			}
		}
	end

	local ml = require("src/moonlight")

	it("brief room descriptions", function()
		ml.options.verbose.roomDescriptions = false
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Hugo")
		-- first look gives full description
		ml:turn ("look")
		-- leaving the room, entering again
		ml:turn ("go up")
		ml:turn ("go down")
		assert.are.same ({"There is a ladder and an oak door here."}, ml.responses)
	end)

	it("brief empty room descriptions", function()
		ml.options.verbose.descriptions = false
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Hugo")
		ml:turn ("go up")
		ml:turn ("go down")
		ml:turn ("go up")
		assert.are.same ({""}, ml.responses)
	end)

	it("verbose room descriptions", function()
		ml.options.verbose.descriptions = true
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Hugo")
		-- first look gives full description
		ml:turn ("look")
		-- leaving the room, entering again
		ml:turn ("go up")
		ml:turn ("go down")
		assert.are.same ({"A tight winding white flaked wooden staircase. There is a ladder and an oak door here."}, ml.responses)
	end)

	pending("list exits in lit rooms", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("go south")
		local expected = {"You cannot go that way."}
		assert.are.same(expected, ml.responses)
	end)

	pending("not list exits in lit rooms", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("go south")
		local expected = {"You cannot go that way."}
		assert.are.same(expected, ml.responses)
	end)

	pending("list contents of opened container", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("go south")
		local expected = {"You cannot go that way."}
		assert.are.same(expected, ml.responses)
	end)

	pending("not list contents of opened container", function()
		ml:setWorld (makeWorld())
		ml:setPlayer ("Alice")
		ml:turn("go south")
		local expected = {"You cannot go that way."}
		assert.are.same(expected, ml.responses)
	end)


end)
