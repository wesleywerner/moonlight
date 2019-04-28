describe ("soundex", function()

	local ml = require("src/moonlight")

	local function makeWorld ()
		return {
			{
				name = "Catacombs",
				description = "A dark and dingy place.",
				contains = {
					{
						name = "indiana",
						person = true
					},
					{
						name = "cucumber sandwich",
						description = "An unexpected surprise in such a place."
					},
					{
						name = "torch",
						description = "A wicked torch mounted on the wall"
					}
				}
			}
		}
	end

	ml:load_world (makeWorld ())
	ml:set_player ("indiana")
	ml.options.soundex = true

	it("matches nouns", function()
		local command = ml:turn ("examine the cucmber sanwich")
		assert.are.equals("cucumber sandwich", command.nouns[1])
	end)

	it("matches nouns", function()
		local command = ml:turn ("examine the cucmber sanwich")
		assert.are.equals("cucumber sandwich", command.nouns[1])
	end)

end)
