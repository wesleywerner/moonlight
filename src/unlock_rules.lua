--- The standard unlocking things rulebook.
-- @module unlock_rules
return function (rulebooks)

	rulebooks.before.unlock = {
		{
			name = "have a door and a key",
			action = function (self, command)
				if not command.item1 then
					if command.nouns[1] then
						return string.format (self.template.unknown["thing"], command.nouns[1]), false
					else
						return self.template.unlock["needs door"], false
					end
				end
				if not command.item2 then
					if command.nouns[2] then
						return string.format (self.template.unknown["thing"], command.nouns[2]), false
					else
						return self.template.unlock["needs key"], false
					end
				end
				if not self:isCarrying (command.item2) then
					return string.format(self.template.thing["not carried"], command.item2.name), false
				end
			end
		},
		{
			name = "thing not lockable",
			action = function (self, command)
				local door = command.item1
				if type(door.locked) == "nil" then
					return self.template.unlock["not lockable"], false
				end
			end
		},
		{
			name = "thing already unlocked",
			action = function (self, command)
				local door = command.item1
				if door.locked == false then
					return self.template.unlock["already unlocked"], false
				end
			end
		},
		{
			name = "with the right key",
			action = function (self, command)
				local utils = require("utils")
				local door = command.item1
				local key = command.item2
				local rightKey = utils.contains (key.unlocks or {}, door.name)
				if not rightKey then
					return self.template.unlock["wont unlock"], false
				end
			end
		}
	}

	rulebooks.on.unlock = {
		{
			name = "unlocking",
			action = function (self, command)
				local door = command.item1
				local key = command.item2
				door.locked = false
				return string.format (self.template.unlock.succeed, door.name, key.name), false
			end
		}

	}

end