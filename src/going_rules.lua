return function (rulebooks)

	--- Test if the command has a direction value.
	local function commandHasDirection (self, command)
		return self.utils.contains(self.options.directions, command.direction)
	end

	rulebooks.before.go = {
		{
			name = "unspecified direction",
			action = function (self, command)
				if not commandHasDirection (self, command) then
					return self.template.whichDirection, false
				end
			end
		},
		{
			name = "room without exits",
			action = function (self, command)
				if type(self.room.exits) ~= "table" then
					return string.format(self.template.noExits, tostring(self.room.name)), false
				end
			end
		},
		{
			name = "exit is a valid room",
			action = function (self, command)
				local room = self:roomByDirection (command.direction)
				if not room then
					return self.template.noExitThatWay, false
				end
			end
		}
	}

	rulebooks.on.go = {
		{
			name = "direction",
			action = function (self, command)
				local room = self:roomByDirection (command.direction)
				if room then
					self:moveItemInto (self.player, room)
					self.room = room
					return self:describeRoom ()
				end
			end
		}
	}

end
