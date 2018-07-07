describe("hook", function()

	local ml = require("src/moonlight")

	local function makeWorld()
		return {
			{
				name = "Lobby",
				contains = {
					{ name="You" },
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

		ml:setWorld (makeWorld())
		ml:setPlayer("You")
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

		ml:setWorld (makeWorld())
		ml:setPlayer("You")
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

		ml:setWorld (makeWorld())
		ml:setPlayer("You")
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

		ml:setWorld (makeWorld())
		ml:setPlayer("You")
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

		ml:setWorld (makeWorld())
		ml:setPlayer("You")
		ml:turn("examine the mailbox")
		assert.are.same({ "It is a mailbox.", expected }, ml.responses)

	end)

	it("receives noun items", function()

		local item1, item2 = nil, nil
		local examine_callback = function(ml, command)
			item1, item2 = command.item1, command.item2
		end
		ml:hook("insert", "mailbox", examine_callback)

		ml:setWorld (makeWorld())
		ml:setPlayer("You")
		ml:turn("put the mailbox in the letter")
		assert.is.not_nil(item1)
		assert.is.not_nil(item2)
		assert.are.equals("mailbox", item1.name)
		assert.are.equals("letter", item2.name)

	end)
end)
