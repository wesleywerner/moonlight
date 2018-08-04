describe ("search", function()

	local ml = require ("moonlight")

	local function makeWorld()
		return {
				{
					name = "Lounge",
					description = "You are in a sparse lounge.",
					contains = {
						{
							name = "Carrie",
							person = true,
						},
						{
							name = "lamp",
							fixed = true
						},
						{
							name = "couch",
							description = "It is a tan couch.",
							supports = { },
							fixed = true,
							hides = {
								{
									name = "silver key",
									description = "A flat silver key."
								}
							}
						}
					}
				},
			}
	end

	it ("negative test", function()
		local expected = {"Your search reveals nothing."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Carrie")
		ml:turn ("search the lamp")
		assert.are.same (expected, ml.output)
	end)

	it ("broad", function()
		local expected = {"Search what?"}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Carrie")
		ml:turn ("search")
		assert.are.same (expected, ml.output)
	end)

	it ("found", function()
		local expected = {"You search the couch.", "You found a silver key."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Carrie")
		ml:turn ("search the couch")
		assert.are.same (expected, ml.output)
	end)

	it ("found examine", function()
		local expected = {"It is a tan couch. On it is a silver key."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Carrie")
		ml:turn ("search the couch")
		ml:turn ("examine the couch")
		assert.are.same (expected, ml.output)
	end)

	it ("found by looking under things", function()
		local expected = {"You search the couch.", "You found a silver key."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Carrie")
		ml:turn ("look under the couch")
		assert.are.same (expected, ml.output)
	end)

end)
