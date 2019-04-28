--- The standard going in directions rulebook.
-- @module going_rules
return function (rulebooks)

	--- Test if the command has a direction value.
	local function commandHasDirection (self, command)
		return self.utils.contains(self.options.directions, command.direction)
	end

	rulebooks.before.go = {
		{
			name = "a direction was specified",
			action = function (self, command)
				if not commandHasDirection (self, command) then
					-- allow going into things (like doors)
					if not command.first_item then
						return self.responses.missing["direction"], false
					end
				end
			end
		},
		{
			name = "the noun has a destination",
			action = function (self, command)
				if command.first_item then
					-- enter a door
					local room = self:room_by_name (command.first_item.destination or "")
					if not room then
						return self.responses.go["not an exit"], false
					end
				end
			end
		},
		{
			name = "the direction has an exit",
			action = function (self, command)
				if not command.first_item then
					-- find the room in the direction
					local room = self:room_by_direction (command.direction)
					if not room then
						return self.responses.go["not an exit"], false
					end
				end
			end
		},
		{
			name = "the noun is open",
			action = function (self, command)
				if command.first_item and (command.first_item.closed == true) then
					return string.format(self.responses.go["through a closed door"], command.first_item.name), false
				end
			end
		}
	}

	rulebooks.on.go = {
		{
			name = "move player to the destination",
			action = function (self, command)
				local room
				if command.first_item then
					-- enter a door
					room = self:room_by_name (command.first_item.destination)
				else
					-- go by direction
					room = self:room_by_direction (command.direction)
				end

				if room then
					self:move_thing_into (self.player, room)
					self.room = room

					-- TODO move to FINALLY timing
					-- call the EXAMINE action after entering a room, so it follows the normal examine rulebook.
					-- The command also carries the BRIEF flag to indicate to examine rules
					-- so that brief room descriptions can be used.
					local cmd = self:parse ("examine")
					cmd.brief = true
					self:simulate (cmd)
				end
			end
		}
	}



end
