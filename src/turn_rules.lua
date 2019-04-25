--- The standard turn rulebook.
-- @module turn_rules
return function (rulebooks)

	rulebooks.before.turn = {
		{
			name = "player exists check",
			action = function (self)
				if self.player == nil then
					return "No player character has been set.", false
				end
			end
		},
		{
			name = "adjust room light level",
			action = function (self, command)
				if self.room.dark == true then
					-- use superpower search options to include dark
					-- rooms, otherwise we won't find a lit thing
					-- in contact with open air.
					local options = {
						includeClosed = false,
						includeDark = true
					}
					-- be careful not to match the room itself,
					-- which can also have a lit value.
					local searchfunc = function (n)
						-- any lit thing that is not the room itself
						return n.lit == true and n ~= self.room
					end
					local lightsource = self:searchFirst (
						searchfunc, self.room, options)
					if lightsource then
						self.room.lit = true
					else
						self.room.lit = false
					end
				end
			end
		}
	}

	rulebooks.after.turn = { }

end
