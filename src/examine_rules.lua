--- The standard examining things rulebook.
-- @module examine_rules
return function (rulebooks)

	rulebooks.before.examine = {
		{
			name = "in the dark",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom and not command.item1 then
					return self.template.darkroomDescription .. self:listRoomExits(), false
				elseif darkroom and command.item1 then
					return self.template.tooDarkForThat, false
				end
			end
		}
	}

	rulebooks.on.examine = {
		{
			name = "the room",
			action = function (self, command)
				if not command.item1 then
					return self:describeRoom ()
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
