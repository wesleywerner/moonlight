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
						},
            {
              name = "lockbox",
              hides = {
								{
									name = "gold key"
								}
              }
            }
					}
				},
			}
	end

	it ("reveals nothing", function()
		local expected = {"Your search reveals nothing."}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("search the lamp")
		assert.are.same (expected, ml.output)
	end)

	it ("thing name not provided", function()
		local expected = {"Search what?"}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("search")
		assert.are.same (expected, ml.output)
	end)

	it ("finds the thing", function()
		local expected = {"You search the couch.", "You found a silver key."}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("search the couch")
		assert.are.same (expected, ml.output)
	end)

	it ("found thing moved on top of supporter", function()
		local expected = {"It is a tan couch. On it is a silver key."}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("search the couch")
		ml:turn ("examine the couch")
		assert.are.same (expected, ml.output)
	end)

	it ("found thing moved into room", function()
		local expected = {"It is a gold key."}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("search the lockbox")
		ml:turn ("examine gold key")
		assert.are.same (expected, ml.output)
	end)

	it ("found thing removes it from the hides table", function()
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("search the lockbox")
    local lockbox = ml:search_first ("lockbox")
		assert.are.same ({}, lockbox.hides)
	end)

	it ("found auto takes things", function()
		ml.options.flags["take things searched"] = true
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("search the couch")
		ml.options.flags["take things searched"] = false
		assert.is.truthy (ml:is_carrying ("silver key"))
	end)

	it ("found by looking under things", function()
		local expected = {"You search the couch.", "You found a silver key."}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("look under the couch")
		assert.are.same (expected, ml.output)
	end)

end)
