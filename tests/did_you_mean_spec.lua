describe("did you mean", function()

	local function makeWorld()
		return {
			{
				name = "Secret Alcove",
				contains = {
					{
						name = "Carrie",
						person = true
					},
					{ name = "red key" },
					{ name = "blue key" }
				}
			}
		}
	end

	local ml = require("src/moonlight")

	pending("prompts on ambiguous noun", function()
		local expected = {"Did you mean the red key or the blue key?"}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("take the key")
		assert.are.same (expected, ml.output)
		-- test the internal state remembers the ambiguous query
		--assert.are.truthy ()
	end)

	pending("accepts a valid response", function()
		local expected = {"You take the blue key"}
		ml:load_world (makeWorld ())
		ml:set_player ("Carrie")
		ml:turn ("take the key")
		ml:turn ("the blue key")
		assert.are.same (expected, ml.output)
	end)

end)
