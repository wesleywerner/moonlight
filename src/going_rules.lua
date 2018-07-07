--- The standard going in directions rulebook.
-- @module going_rules
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
					-- allow going into things (like doors)
					if not command.item1 then
						return self.template.whichDirection, false
					end
				end
			end
		},
		{
			name = "room has exits",
			action = function (self, command)
				if type(self.room.exits) ~= "table" then
					return string.format(self.template.noExits, tostring(self.room.name)), false
				end
			end
		},
		{
			name = "exit is a valid room",
			action = function (self, command)
				if command.item1 then
					-- enter a door
					local room = self:roomByName (command.item1.destination or "")
					if not room then
						return self.template.noExitThatWay, false
					end
				else
					-- find the room in the direction
					local room = self:roomByDirection (command.direction)
					if not room then
						return self.template.noExitThatWay, false
					end
				end
			end
		}
	}

	rulebooks.on.go = {
		{
			name = "direction",
			action = function (self, command)
				local room
				if command.item1 then
					-- enter a door
					room = self:roomByName (command.item1.destination)
				else
					-- go by direction
					room = self:roomByDirection (command.direction)
				end

				if room then
					self:moveItemInto (self.player, room)
					self.room = room
					return self:describeRoom ()
				end
			end
		}
	}

end
