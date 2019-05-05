describe ("parser", function()

	local ml = require("src/moonlight")
	local parser = require("src/parser")

	local options = {
		directions = ml.options.directions,
		ignores = ml.options.ignores,
		synonyms = ml.options.synonyms
		}

	it ("does not confuse nouns with similar names", function()
		options.known_nouns = {"blue door", "blue key", "red door","red key"}
		local result = parser("unlock the red door with the red key", options)
		local expected = {
			verb="unlock",
			nouns={"red door", "red key", "key"}
			}
		assert.are.same(expected, result)
	end)

	it ("reads verb and noun", function()
		options.known_nouns = {"door"}
		local result = parser("open door", options)
		local expected = {
			verb="open",
			nouns={"door"}
			}
		assert.are.same(expected, result)
	end)

	it ("skips ignored words", function()
		options.known_nouns = {"door"}
		local result = parser("open the door", options)
		local expected = {
			verb="open",
			nouns={"door"}
			}
		assert.are.same(expected, result)
	end)

	it ("reads multiple nouns - full sentence", function()
		options.known_nouns = {"gate", "skeleton key"}
		local result = parser("unlock the gate with the skeleton key", options)
		local expected = {
			verb="unlock",
			nouns={"gate","skeleton key"}
			}
		assert.are.same(expected, result)
	end)

	it ("reads multiple nouns - shorthand", function()
		options.known_nouns = {"gate", "skeleton key"}
		local result = parser("unlock gate with key", options)
		local expected = {
			verb="unlock",
			nouns={"gate","skeleton key"}
			}
		assert.are.same(expected, result)
	end)

	it ("reads unknown nouns", function()
		options.known_nouns = {"wise guy", "computer"}
		local result = parser("ask the wise guy about an unseen tablet", options)
		local expected = {
			verb="ask",
			nouns={"wise guy", "unseen", "tablet"}
			}
		assert.are.same(expected, result)
	end)

	it ("interprets verb synonym: look/examine", function()
		options.known_nouns = {"gate"}
		local result = parser("look at the gate", options)
		local expected = {
			verb="examine",
			nouns={"gate"}
			}
		assert.are.same(expected, result)
	end)

	it ("interprets verb synonym: get/take", function()
		options.known_nouns = {"apple"}
		local result = parser("get an apple", options)
		local expected = {
			verb="take",
			nouns={"apple"}
			}
		assert.are.same(expected, result)
	end)

	it ("interprets verb synonym: put/insert", function()
		options.known_nouns = {"box", "table"}
		local result = parser("put the box on the table", options)
		local expected = {
			verb="insert",
			nouns={"box","table"}
			}
		assert.are.same(expected, result)
	end)

	it ("interprets verb synonym: x/examine", function()
		options.known_nouns = {"red apple"}
		local result = parser("x red apple", options)
		local expected = {
			verb="examine",
			nouns={"red apple"}
			}
		assert.are.same(expected, result)
	end)

	it ("interprets verb synonym: i/inventory", function()
		options.known_nouns = nil
		local result = parser("i", options)
		local expected = {
			verb="inventory",
			nouns={ }
			}
		assert.are.same(expected, result)
	end)

	it ("recognises multi-word nouns", function()
		options.known_nouns = {"old man"}
		local result = parser("talk to the old man", options)
		local expected = {
			verb="talk",
			nouns={"old man"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognises partial multi-word nouns", function()
		options.known_nouns = {"red stone", "blue stone"}
		local result = parser("take red", options)
		local expected = {
			verb="take",
			nouns={"red stone"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognises known nouns: the wise guy A", function()
		options.known_nouns = {"wise guy", "computer"}
		local result = parser("ask the wise guy about the computer", options)
		local expected = {
			verb="ask",
			nouns={"wise guy", "computer"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognises known nouns: the wise guy (lazy)", function()
		options.known_nouns = {"wise guy", "computer"}
		local result = parser("ask guy the computer", options)
		local expected = {
			verb="ask",
			nouns={"wise guy", "computer"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognises known nouns: the wormwood herb", function()
		options.known_nouns = {"wormwood herb"}
		local result = parser("eat herb", options)
		local expected = {
			verb="eat",
			nouns={"wormwood herb"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognises directions: going northwest", function()
		options.known_nouns = nil
		local result = parser("go northwest", options)
		local expected = {
			verb="go",
			direction="northwest",
			nouns={ }
			}
		assert.are.same(expected, result)
	end)

	it ("recognises directions: looking east", function()
		options.known_nouns = nil
		local result = parser("look e", options)
		local expected = {
			verb="examine",
			direction="east",
			nouns={ }
			}
		assert.are.same(expected, result)
	end)

	it ("recognises directions: in", function()
		options.known_nouns = {"mirror"}
		local result = parser("look in mirror", options)
		local expected = {
			verb="examine",
			nouns={"mirror"},
			direction="in"
			}
		assert.are.same(expected, result)
	end)

	it ("does not confuse verbs for nouns", function()
		options.known_nouns = {"small mailbox"}
		local result = parser("x", options)
		local expected = {
			verb="examine",
			nouns = { }
		}
		assert.are.same(expected, result)
	end)

	it ("matches items with hyphens", function()
		local expected = {"A small bio-fridge."}
		ml:load_world ({
			{
				name = "Bio Lab",
				contains = {
					{
						name = "Hugo",
						person = true
					},
					{
						name = "bio-fridge",
						description = "A small bio-fridge."
					}
				}
			}})
		ml:set_player ("Hugo")
		local command = ml:turn ("examine bio-fridge")
		assert.are.same (expected, ml.output)
	end)

end)
