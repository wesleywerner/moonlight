describe("hook", function()

	local ml = require("src/moonlight")
	
	local local_bool = false
	
	local examine_callback = function(ml, command)
		local_bool = true
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

end)
