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

	it("sets with specific verb/noun combination", function()

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

	it("does not set with unrelated noun", function()

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

	it("does not set with unrelated verb", function()

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

	it("sets with custom response", function()

		local expected = "A magical force prevents you from examining the mailbox"
		local examine_callback = function(ml, command)
			if command.verb == "examine" and command.nouns[1] == "mailbox" then
				return true, expected
			end
		end
		ml:hook("examine", "mailbox", examine_callback)

		ml.world = makeWorld()
		ml:turn("examine the mailbox")
		assert.are.same({ expected }, ml.responses)

	end)

	it("does not set with custom response", function()

		local expected = "You sense something magical about the mailbox."
		local examine_callback = function(ml, command)
			if command.verb == "examine" and command.nouns[1] == "mailbox" then
				return false, expected
			end
		end
		ml:hook("examine", "mailbox", examine_callback)

		ml.world = makeWorld()
		ml:turn("examine the mailbox")
		assert.are.same({ "It is a mailbox.", expected }, ml.responses)

	end)

end)
