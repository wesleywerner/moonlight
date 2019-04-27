--- The standard unlocking things rulebook.
-- @module unlock_rules
return function (rulebooks)

	rulebooks.before.unlock = {
		{
			name = "the player refers to a door",
			action = function (self, command)
				-- Test that a door is referred in the command
				if not command.item1 then
					if command.nouns[1] then
						return string.format (self.responses.unknown["thing"], command.nouns[1]), false
					else
						return self.responses.unlock["needs door"], false
					end
				end
				-- Test that a key is referred in the command
				if not command.item2 then
					if command.nouns[2] then
						return string.format (self.responses.unknown["thing"], command.nouns[2]), false
					else
						return self.responses.unlock["needs key"], false
					end
				end
			end
		},
		{
			name = "the player carries the key",
			action = function (self, command)
				if not self:isCarrying (command.item2) then
					return string.format(self.responses.thing["not carried"], command.item2.name), false
				end
			end
		},
		{
			name = "the door is lockable",
			action = function (self, command)
				local door = command.item1
				if type(door.locked) == "nil" then
					return self.responses.unlock["not lockable"], false
				end
			end
		},
		{
			name = "the door is not already unlocked",
			action = function (self, command)
				local door = command.item1
				if door.locked == false then
					return self.responses.unlock["already unlocked"], false
				end
			end
		},
		{
			name = "the key matches the door",
			action = function (self, command)
				local utils = require("utils")
				local door = command.item1
				local key = command.item2
				local rightKey = utils.contains (key.unlocks or {}, door.name)
				if not rightKey then
					return self.responses.unlock["wont unlock"], false
				end
			end
		}
	}

	rulebooks.on.unlock = {
		{
			name = "unlock the door",
			action = function (self, command)
				local door = command.item1
				local key = command.item2
				door.locked = false
			end
		},
	}

	rulebooks.after.unlock = {
		{
			name = "report",
			action = function (self, command)
				local door = command.item1
				local key = command.item2
				return string.format (self.responses.unlock.succeed, door.name, key.name)
			end
		},
		{
			-- TODO move into the FINALLY timing
			name = "apply the open-unlocked-things option",
			action = function (self, command)
				if self.options.auto["open unlocked things"] then
					self.applyCommand (self, { verb = "open", item1 = command.item1 })
				end
			end
		}
	}

end
