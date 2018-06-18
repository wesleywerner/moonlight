describe("hook", function()

	local ml = require("src/moonlight")
	ml.world = {
		["lobby"] = {
			["contains"] = {
				{ player=true },
				{ name="mailbox"},
				{ name="letter"},
			}
		}
	}

	local local_bool = false

	local examine_callback = function(ml, verb, noun, command)
		if verb == "examine" and noun == "mailbox" then
			local_bool = true
		end
	end

	ml:hook("examine", "mailbox", examine_callback)

	local go_callback = function(ml, command)
		if command.direction == "n" then
			return false
		end
	end

	ml:hook("go", nil, go_callback)

	it("triggers a specific verb/noun combination", function()
		local_bool = false
		ml:turn("examine the mailbox")
		assert.is_true(local_bool)
	end)

	it("does not trigger an unrelated noun", function()
		local_bool = false
		ml:turn("examine the letter")
		assert.is_false(local_bool)
	end)

	it("does not trigger an unrelated verb", function()
		local_bool = false
		ml:turn("open the mailbox")
		assert.is_false(local_bool)
	end)

	pending("stops further processing", function()
		ml:turn("go n")
		assert.are.equal(expected, obj)
	end)

	pending("stops further processing", function()
		ml:turn("go n")
		assert.are.equal(expected, obj)
	end)

	pending("failed action with custom response", function()

	end)

	pending("successful action with custom response", function()

	end)

end)
