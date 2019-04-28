describe("examine", function()

	local function makeWorld()
		return {
			-- room
			{
				name = "Lobby",
				description = "You are in the hotel lobby.",
				contains = {
					{
						name = "You",
						description = "As good looking as ever.",
						person = true
					},
					{
						name = "bookcase",
						description = "It is just wooden box without the books.",
						contains = {
							{
								name = "envelope"
							}
						},
						supports = {
							{
								name = "key"
							}
						}
					},
					{
						name = "podium",
						description = "A short podium supporting a bowl.",
						fixed = true,
						supports = {
							{
								name = "bowl",
								description = "An opaque blue bowl.",
								contains = {
									{
										name = "mint",
										description = "A small round, white peppermint.",
										edible = true
									}
								}
							}
						}
					},
					{
						name = "Mary",
						description = "As good looking as ever.",
						person = true
					},
				}
			},
			-- room
			{
				name = "Empty Space",
				contains = {
					{ name = "Bob", person = true }
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("room with description", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("look")
		local expected = "You are in the hotel lobby. There is a bookcase, a podium and Mary here."
		assert.are.equals(expected, ml.output[1])
	end)

	pending("room without description", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("look in the bowl")
		local expected = "An opaque blue bowl. Inside it is a mint."
		assert.are.equals(expected, ml.output[1])
	end)

	it("a supporter", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("x podium")
		local expected = "A short podium supporting a bowl. On it is a bowl."
		assert.are.equals(expected, ml.output[1])
	end)

	it("a supporting container", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("examine bookcase")
		local expected = "It is just wooden box without the books. Inside it is an envelope. On it is a key."
		assert.are.equals(expected, ml.output[1])
	end)

	it("an unknown thing", function()
		ml:load_world (makeWorld())
		ml:set_player("You")
		ml:turn("examine the snargle")
		local expected = "I don't see the snargle."
		assert.are.equals(expected, ml.output[1])
	end)

end)

describe ("things", function()

	local function makeWorld()
		return {
			{
				name = "Serene Pond",
				description = "You are near a small, calm pond.",
				contains = {
					{
						name = "You",
						person = true
					},
					{
						name = "orchid",
						description = "A delicate flower of some kind.",
						appearance = "You notice an orchid hanging nearby."
					},
					{
						name = "pond",
						description = "pond description.",
						appearance = ""
					},
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("with appearance", function()
		-- things with a customized "appearance" property
		local expected = {"You are near a small, calm pond. You notice an orchid hanging nearby."}
		ml:load_world (makeWorld ())
		ml:set_player ("You")
		ml:turn ("look")

		assert.are.same(expected, ml.output)
	end)

end)
