--- The standard examining things rulebook.
-- @module examine_rules
return function (rulebooks)

	rulebooks.before.examine = {
		{
			name = "the noun exists",
			action = function (self, command)
				if command.first_noun and not command.first_item then
					return string.format(self.responses.unknown["thing"], command.first_noun), false
				end
			end
		},
		{
			name = "the room is lit",
			action = function (self, command)
				if self.room.is_dark then
					return self.responses.examine["in the dark"] .. " " .. self:listRoomExits(), false
				end
			end
		},
	}

	rulebooks.on.examine = {
		{
			name = "describe the room",
			action = function (self, command)
				if not command.first_item then
					return self:describeRoom (command.brief)
				end
			end
		},
		{
			name = "describe the noun",
			action = function (self, command)
				if command.first_item then
					return self:describe (command.first_item)
				end
			end
		}
	}

end
