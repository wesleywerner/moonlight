--- The standard inventory listing rulebook.
-- @module inventory_rules
return function (rulebooks)

	rulebooks.before.inventory = {
		{
			name = "in the dark",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom then
					return self.template.tooDarkForThat, false
				end
			end
		},
		{
			name = "listing in the dark",
			action = function (self)
				--return "it is too dark.", false
			end
		}
	}

	rulebooks.on.inventory = {
		{
			name = "listing",
			action = function (self)
				return self:listInventory()
			end
		}
	}

end
