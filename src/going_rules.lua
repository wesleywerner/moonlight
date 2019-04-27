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
					if not command.item1 then
						return self.responses.missing["direction"], false
					end
				end
			end
		},
		{
			name = "the noun has a destination",
			action = function (self, command)
				if command.item1 then
					-- enter a door
					local room = self:roomByName (command.item1.destination or "")
					if not room then
						return self.responses.go["not an exit"], false
					end
				end
			end
		},
		{
			name = "the direction has an exit",
			action = function (self, command)
				if not command.item1 then
					-- find the room in the direction
					local room = self:roomByDirection (command.direction)
					if not room then
						return self.responses.go["not an exit"], false
					end
				end
			end
		},
		{
			name = "the noun is open",
			action = function (self, command)
				if command.item1 and (command.item1.closed == true) then
					return string.format(self.responses.go["through a closed door"], command.item1.name), false
				end
			end
		}
	}

	rulebooks.on.go = {
		{
			name = "move player to the destination",
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
					self:moveIn (self.player, room)
					self.room = room

					-- TODO move to SAY/REPORT timing
					-- call the EXAMINE action after entering a room, so it follows the normal examine rulebook.
					-- The command also carries the allow_brief flag to indicate to examine rules
					-- that brief room descriptions can be used.
					self:applyCommand ({ verb = "examine", nouns = {}, brief = true })
				end
			end
		}
	}



end
