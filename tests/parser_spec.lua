describe ("parser", function()

	local ml = require("src/moonlight")

	local options = {
		directions = ml.options.directions,
		ignores = ml.options.ignores,
		synonyms = ml.options.synonyms
		}

	it ("verb noun", function()
		options.known_nouns = nil
		local result = ml.api.parse("open door", options)
		local expected = {
			verb="open",
			nouns={"door"}
			}
		assert.are.same(expected, result)
	end)

	it ("ignored words", function()
		options.known_nouns = nil
		local result = ml.api.parse("open the door", options)
		local expected = {
			verb="open",
			nouns={"door"}
			}
		assert.are.same(expected, result)
	end)

	it ("listing nouns: the gargoyle", function()
		options.known_nouns = nil
		local result = ml.api.parse("give sword to gargoyle", options)
		local expected = {
			verb="give",
			nouns={"sword","gargoyle"}
			}
		assert.are.same(expected, result)
	end)

	it ("listing nouns: the gate and the skeleton key", function()
		options.known_nouns = {"gate", "skeleton key"}
		local result = ml.api.parse("unlock the gate with the skeleton key", options)
		local expected = {
			verb="unlock",
			nouns={"gate","skeleton key"}
			}
		assert.are.same(expected, result)
	end)

	it ("listing nouns: the gate and the skeleton key (lazy)", function()
		options.known_nouns = {"gate", "skeleton key"}
		local result = ml.api.parse("unlock gate skel", options)
		local expected = {
			verb="unlock",
			nouns={"gate","skeleton key"}
			}
		assert.are.same(expected, result)
	end)

	it ("listing nouns: the unseen tablet", function()
		options.known_nouns = {"wise guy", "computer"}
		local result = ml.api.parse("ask the wise guy about an unseen tablet", options)
		local expected = {
			verb="ask",
			nouns={"wise guy", "unseen", "tablet"}
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: look/examine", function()
		options.known_nouns = nil
		local result = ml.api.parse("look at the gate", options)
		local expected = {
			verb="examine",
			nouns={"gate"}
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: get/take", function()
		options.known_nouns = nil
		local result = ml.api.parse("get an apple", options)
		local expected = {
			verb="take",
			nouns={"apple"}
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: put/insert", function()
		options.known_nouns = nil
		local result = ml.api.parse("put the box on the table", options)
		local expected = {
			verb="insert",
			nouns={"box","table"}
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: x/examine", function()
		options.known_nouns = {"red apple"}
		local result = ml.api.parse("x red apple", options)
		local expected = {
			verb="examine",
			nouns={"red apple"}
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: i/inventory", function()
		options.known_nouns = nil
		local result = ml.api.parse("i", options)
		local expected = {
			verb="inventory",
			nouns={ }
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the old man", function()
		options.known_nouns = {"old man"}
		local result = ml.api.parse("talk to the old man", options)
		local expected = {
			verb="talk",
			nouns={"old man"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the red stone", function()
		options.known_nouns = {"red stone", "blue stone"}
		local result = ml.api.parse("take red", options)
		local expected = {
			verb="take",
			nouns={"red stone"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the wise guy", function()
		options.known_nouns = {"wise guy", "computer"}
		local result = ml.api.parse("ask the wise guy about the computer", options)
		local expected = {
			verb="ask",
			nouns={"wise guy", "computer"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the wise guy (lazy)", function()
		options.known_nouns = {"wise guy", "computer"}
		local result = ml.api.parse("ask guy the comp", options)
		local expected = {
			verb="ask",
			nouns={"wise guy", "computer"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the wormwood herb", function()
		options.known_nouns = {"wormwood herb"}
		local result = ml.api.parse("eat herb", options)
		local expected = {
			verb="eat",
			nouns={"wormwood herb"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing directions: going northwest", function()
		options.known_nouns = nil
		local result = ml.api.parse("go northwest", options)
		local expected = {
			verb="go",
			direction="northwest",
			nouns={ }
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing directions: looking east", function()
		options.known_nouns = nil
		local result = ml.api.parse("look e", options)
		local expected = {
			verb="examine",
			direction="east",
			nouns={ }
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing directions: in", function()
		options.known_nouns = nil
		local result = ml.api.parse("look in mirror", options)
		local expected = {
			verb="examine",
			nouns={"mirror"},
			direction="in"
			}
		assert.are.same(expected, result)
	end)

	it ("does not confuse verbs for nouns", function()
		options.known_nouns = {"small mailbox"}
		local result = ml.api.parse("x", options)
		local expected = {
			verb="examine",
			nouns = { }
		}
		assert.are.same(expected, result)
	end)


end)
