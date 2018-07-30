describe ("it", function()

	local ml = require ("moonlight")

	local function makeWorld()
		return {
			{
				name = "A small room",
				description = "You are in a small room.",
				contains = {
					{ name = "Wes", person = true },
					{ name = "cup of coffee", edible = true }
				}
			}
		}
	end

	it ("refers to last observed thing", function()
		local expected = {"You take the cup of coffee."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Wes")
		ml:turn ("examine the coffee")
		ml:turn ("take it")
		assert.are.same (expected, ml.responses)
	end)

	it ("works multiple times", function()
		local expected = {"You drop the cup of coffee."}
		ml:setWorld (makeWorld ())
		ml:setPlayer ("Wes")
		ml:turn ("examine the coffee")
		ml:turn ("take it")
		ml:turn ("examine it")
		ml:turn ("drop it")
		assert.are.same (expected, ml.responses)
	end)

end)
