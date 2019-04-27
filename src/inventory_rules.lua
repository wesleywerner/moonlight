--- The standard inventory listing rulebook.
-- @module inventory_rules
return function (rulebooks)

	rulebooks.before.inventory = {
		{
			name = "there is enough light",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom then
					return self.responses.inventory["in the dark"], false
				end
			end
		}
	}

	rulebooks.on.inventory = {
		{
			name = "list inventory",
			action = function (self)
				return self:listInventory()
			end
		}
	}

end
