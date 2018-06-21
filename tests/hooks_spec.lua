describe("hook", function()

	local ml = require("src/moonlight")

	local function makeWorld()
		return {
			["lobby"] = {
				["contains"] = {
					{ player=true },
					{ name="mailbox"},
					{ name="letter"},
				}
			}
		}
	end

	it("triggers a specific verb/noun combination", function()

		local local_bool = false
		local examine_callback = function(ml, command)
			if command.verb == "examine" and command.nouns[1] == "mailbox" then
				local_bool = true
			end
		end
		ml:hook("examine", "mailbox", examine_callback)

		ml.world = makeWorld()
		ml:turn("examine the mailbox")
		assert.is_true(local_bool)

	end)

	it("does not trigger an unrelated noun", function()

		local local_bool = false
		local examine_callback = function(ml, command)
			if command.verb == "examine" and command.nouns[1] == "mailbox" then
				local_bool = true
			end
		end
		ml:hook("examine", "mailbox", examine_callback)

		ml.world = makeWorld()
		ml:turn("examine the letter")
		assert.is_false(local_bool)

	end)

	it("does not trigger an unrelated verb", function()

		local local_bool = false
		local examine_callback = function(ml, command)
			if command.verb == "examine" and command.nouns[1] == "mailbox" then
				local_bool = true
			end
		end
		ml:hook("examine", "mailbox", examine_callback)

		ml.world = makeWorld()
		ml:turn("open the mailbox")
		assert.is_false(local_bool)

	end)

	it("failed action with custom response", function()

		local expected = "A magical force prevents you from examining the mailbox"
		local examine_callback = function(ml, command)
			if command.verb == "examine" and command.nouns[1] == "mailbox" then
				ml:respond (expected)
				return false
			end
		end
		ml:hook("examine", "mailbox", examine_callback)

		ml.world = makeWorld()
		ml:turn("examine the mailbox")
		assert.are.equals(expected, ml.responses[1])
		assert.are.same({ expected }, ml.responses)

	end)

	pending("successful action with custom response", function()

	end)

end)
