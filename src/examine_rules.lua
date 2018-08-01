--- The standard examining things rulebook.
-- @module examine_rules
return function (rulebooks)

	rulebooks.before.examine = {
		{
			name = "unspecified nouns",
			action = function (self, command)
				if command.nouns[1] and not command.item1 then
					return string.format(self.template.unknown["thing"], command.nouns[1]), false
				end
			end
		},
		{
			name = "in the dark",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom then
					return self.template.examine["in the dark"] .. " " .. self:listRoomExits(), false
				end
			end
		},
	}

	rulebooks.on.examine = {
		{
			name = "the room",
			action = function (self, command)
				if not command.item1 then
					return self:describeRoom (command.brief)
				end
			end
		},
		{
			name = "a known thing",
			action = function (self, command)
				if command.item1 then
					return self:describe (command.item1)
				end
			end
		}
	}

end
