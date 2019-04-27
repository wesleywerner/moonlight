--- The standard examining things rulebook.
-- @module examine_rules
return function (rulebooks)

	rulebooks.before.examine = {
		{
			name = "the noun exists",
			action = function (self, command)
				if command.nouns[1] and not command.item1 then
					return string.format(self.responses.unknown["thing"], command.nouns[1]), false
				end
			end
		},
		{
			name = "the room is lit",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom then
					return self.responses.examine["in the dark"] .. " " .. self:listRoomExits(), false
				end
			end
		},
	}

	rulebooks.on.examine = {
		{
			name = "describe the room",
			action = function (self, command)
				if not command.item1 then
					return self:describeRoom (command.brief)
				end
			end
		},
		{
			name = "describe the noun",
			action = function (self, command)
				if command.item1 then
					return self:describe (command.item1)
				end
			end
		}
	}

end
