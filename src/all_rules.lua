--- The standard rulebook for applying commands to ALL things.
-- This rulebook handles testing if the given verb is actionable as
-- a bulk command. the command item2 value would be the item to apply
-- the bulk action, otherwise the room if no item2 is present.
-- @module all_rules
return function (rulebooks)

	rulebooks.all = rulebooks.all or { }

	rulebooks.all.take = {
		{
			name = "from something that contains",
			action = function (self, command)
				if command.item2 then
					if (not command.item2.contains) and (not command.item2.supports) then
						return string.format(self.template.take["not container"], command.item2.name), false
					end
				end
			end
		},
		{
			name = "from an open container",
			action = function (self, command)
				if command.item2 then
					if (command.item2.closed) then
						return string.format(self.template.take["from closed container"], command.item2.name), false
					end
				end
			end
		},
		{
			-- taking all looks at the specified thing or the room
			name = "redirect taking from",
			action = function (self, command)
				command.allFrom = command.item2 or self.room
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
				if command.item2.closed == true then
					return string.format(self.template.insert["into closed"], command.item2.name), false
				end
			end
		}
	}

end
