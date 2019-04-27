--- The standard taking things rulebook.
-- @module take_rules
return function (rulebooks)

	rulebooks.before.take = {
		{
			name = "the noun exists",
			action = function (self, command)
				if not command.first_item then
					if not command.first_noun then
						return string.format(self.responses.missing["noun"], command.verb), false
					else
						return string.format(self.responses.unknown["thing"], command.first_noun), false
					end
				end
			end
		},
		{
			name = "in the dark",
			action = function (self, command)
				if self.room.is_dark then
					return self.responses.take["in the dark"], false
				end
			end
		},
		{
			name = "not taking a person",
			action = function (self, command)
				if command.first_item.person then
					return string.format(self.responses.take["person"], command.first_item.name), false
				end
			end
		},
		{
			name = "the noun is not fixed in place",
			action = function (self, command)
				if command.first_item.fixed then
					-- the fixed value can be custom text
					if type(command.first_item.fixed) == "string" then
						return command.first_item.fixed, false
					else
						return string.format(self.responses.thing["fixed"], command.first_item.name), false
					end
				end
			end
		},
		{
			name = "the noun is not already carried",
			action = function (self, command)
				if self:isCarrying (command.first_item) then
					return self.responses.take["when carried"], false
				end
			end
		}
	}

	rulebooks.on.take = {
		{
			name = "take the noun",
			action = function (self, command)
				self:moveIn (command.first_item, self.player)
			end
		}
	}

	rulebooks.after.take = {
		{
			name = "report",
			action = function (self, command)
				return string.format(self.responses.take["success"], command.first_item.name)
			end
		}
	}

end
