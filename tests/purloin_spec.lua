describe ("purloin", function()

	local ml = require ("moonlight")

	local function makeWorld()
		return {
			{
				name = "Garden",
				contains = {
					{ name = "Carrie", person = true },
					{ name = "Bob", person = true,
						contains = {
							{ name = "topaz ring" }
						}
					}
				}
			},
			{
				name = "Beach",
				contains = {
					{
						name = "locked box",
						closed = true,
						locked = true,
						contains = {
							{ name = "ice cream" }
						}
					},
					{
						name = "umbrella"
					},
					{
						name = "shack",
						fixed = true
					},
				}
			}
		}
	end

	it ("something in another room", function()
		local expected = {"The umbrella magically appears in your pocket."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Carrie")
		ml:turn ("purloin the umbrella")
		assert.are.same (expected, ml.output)
	end)

	it ("something in a closed container", function()
		local expected = {"The ice cream magically appears in your pocket."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Carrie")
		ml:turn ("purloin the ice")
		assert.are.same (expected, ml.output)
	end)

	it ("something carried by somebody else", function()
		local expected = {"The topaz ring magically appears in your pocket."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Carrie")
		ml:turn ("purloin the topaz ring")
		assert.are.same (expected, ml.output)
	end)

	it ("something that does not exist", function()
		local expected = {"\"snafu\" not found in this world."}
		ml:setWorld (makeWorld())
		ml:setPlayer ("Carrie")
		ml:turn ("purloin the snafu")
		assert.are.same (expected, ml.output)
	end)

	it ("when debug commands are disabled", function()
		-- should be able to disable purloin and similar future commands
		local expected = {"I don't know what \"purloin\" means."}
		ml.options.testing = false
		ml:setWorld (makeWorld())
		ml:setPlayer ("Carrie")
		ml:turn ("purloin the snafu")
		assert.are.same (expected, ml.output)
	end)

end)
