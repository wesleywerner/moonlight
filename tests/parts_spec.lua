describe ("parts of things", function()

	local function makeWorld()
		return {
			{
				name = "Biologoy Lab",
				description = "You are in the Biology Lab.",
				contains = {
					{
						name = "Hugo",
						person = true
					},
					{
						name = "oven",
						fixed = "The oven is securely mounted on the wall.",
						description = "It is a small square oven used for incinerating lab samples.",
						contains = { },
						open = true,
						parts = {
							{
								name = "button",
								fixed = "You can't remove the button.",
								description = "A push-button that fires up the oven."
							},
							{
								name = "label",
								description = "It has the numbers 2517 printed on it."
							}
						}
					}
				}
			}
		}
	end

	local ml = require("src/moonlight")

	it("do not list in room descriptions", function()
		local expected = {"You are in the Biology Lab. There is an oven here."}
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		ml:turn ("look")
		assert.are.same (expected, ml.output)
	end)

	it("do not list in thing descriptions", function()
		local expected = {"It is a small square oven used for incinerating lab samples."}
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		ml:turn ("examine oven")
		assert.are.same (expected, ml.output)
	end)

	it("can be taken when not fixed", function()
		local expected = {"You take the label."}
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		ml:turn ("take the label")
		assert.are.same (expected, ml.output)
	end)

	it("can be examined", function()
		local expected = {"A push-button that fires up the oven."}
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		ml:turn ("examine the button")
		assert.are.same (expected, ml.output)
	end)

	it("can't be taken when fixed", function()
		local expected = {"You can't remove the button."}
		ml:load_world (makeWorld ())
		ml:set_player ("Hugo")
		ml:turn ("take the button")
		assert.are.same (expected, ml.output)
	end)

end)
