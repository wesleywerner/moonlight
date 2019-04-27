--- The standard rulebook for applying commands to ALL things.
-- This rulebook handles testing if the given verb is actionable as
-- a bulk command. the command second_item value would be the item to apply
-- the bulk action, otherwise the room if no second_item is present.
-- @module all_rules
return function (rulebooks)

	rulebooks.all = rulebooks.all or { }

	rulebooks.all.take = {
		{
			name = "the second noun contains things",
			action = function (self, command)
				if command.second_item then
					if (not command.second_item.contains) and (not command.second_item.supports) then
						return string.format(self.responses.take["not container"], command.second_item.name), false
					end
				end
			end
		},
		{
			name = "the second noun is an open container",
			action = function (self, command)
				if command.second_item then
					if (command.second_item.closed) then
						return string.format(self.responses.take["from closed container"], command.second_item.name), false
					end
				end
			end
		},
		{
			-- taking all looks at the specified thing or the room
			name = "redirect taking from",
			action = function (self, command)
				command.allFrom = command.second_item or self.room
			end
		}
	}

	rulebooks.all.insert = {
		{
			-- inserting all looks at the player inventory
			name = "redirect inserting from inventory",
			action = function (self, command)
				command.allFrom = self.player
			end
		},
		{
			name = "into a closed container",
			action = function (self, command)
				if command.second_item.closed == true then
					return string.format(self.responses.insert["into closed"], command.second_item.name), false
				end
			end
		}
	}

end
