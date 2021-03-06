describe("rulebook", function()

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

	it("triggers my examine rule", function()

		ml:reset_simulation()
		ml:load_world (makeWorld())
		ml:set_player("You")

		local local_bool = false

		local examine_rule = {
			name = "my examine rule",
			action = function (self, command)
				if command.nouns[1] == "mailbox" then
					local_bool = true
				end
			end
		}

		table.insert(ml.rulebooks.on.examine, examine_rule)

		ml:turn("examine the mailbox")
		assert.is_true(local_bool)

	end)

	it("does not trigger with unrelated verb", function()

		ml:reset_simulation()
		ml:load_world (makeWorld())
		ml:set_player("You")

		local local_bool = false

		local examine_rule = {
			name = "my examine rule",
			action = function (self, command)
				if command.nouns[1] == "mailbox" then
					local_bool = true
				end
			end
		}

		table.insert(ml.rulebooks.on.examine, examine_rule)

		ml:turn("open the mailbox")
		assert.is_false(local_bool)

	end)

	it("prevents the action with custom response", function()

		ml:reset_simulation()
		ml:load_world (makeWorld())
		ml:set_player("You")

		local expected = "A magical force prevents you from examining the mailbox"

		local examine_rule = {
			name = "my examine rule",
			action = function (self, command)
				if command.nouns[1] == "mailbox" then
					return expected, false
				end
			end
		}

		table.insert(ml.rulebooks.before.examine, examine_rule)

		ml:turn("examine the mailbox")
		assert.are.same({expected}, ml.output)

	end)

	it("pass through with custom response", function()

		ml:reset_simulation()
		ml:load_world (makeWorld())
		ml:set_player("You")

		local expected = "A magical force prevents you from examining the mailbox"

		local examine_rule = {
			name = "my examine rule",
			action = function (self, command)
				if  command.nouns[1] == "mailbox" then
					return expected
				end
			end
		}

		table.insert(ml.rulebooks.before.examine, examine_rule)

		ml:turn("examine the mailbox")
		assert.are.same({expected, "It is a mailbox."}, ml.output)

	end)


	it("before every turn rule", function()

		ml:reset_simulation()
		ml:load_world (makeWorld())
		ml:set_player("You")

		local counter = 0

		local turnAction = function (self, command)
			if command.verb == "turn" then
				counter = counter + 1
			end
		end

		ml.rulebooks:addBefore("turn", "my turn counter rule", turnAction)

		ml:turn("examine the mailbox")
		ml:turn("look")
		ml:turn("take the letter")
		assert.are.equals(3, counter)

	end)

	it("after every turn rule", function()

		ml:reset_simulation()
		ml:load_world (makeWorld())
		ml:set_player("You")

		local counter = 0

		local turnAction = function (self, command)
			if command.verb == "turn" then
				counter = counter + 1
			end
		end

		ml.rulebooks:addAfter("turn", "my turn counter rule", turnAction)

		ml:turn("examine the mailbox")
		ml:turn("look")
		ml:turn("take the letter")
		assert.are.equals(3, counter)

	end)

end)
