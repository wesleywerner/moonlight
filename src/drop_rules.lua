--- The standard dropping things rulebook.
-- @module drop_rules
return function (rulebooks)
	rulebooks.before.drop =	{
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
			name = "the player is carrying the noun",
			action = function (self, command)
				if not self:is_carrying (command.first_item) then
					return string.format(self.responses.thing["not carried"], command.first_item.name), false
				end
			end
		}
	}

	rulebooks.on.drop = {
		{
			name = "drop the noun in the room",
			action = function (self, command)
				self:move_thing_into (command.first_item, self.room)
				return string.format(self.responses.drop["success"], command.first_item.name)
			end
		}
	}
end
