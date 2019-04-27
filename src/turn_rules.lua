--- The standard turn rulebook.
-- @module turn_rules
return function (rulebooks)

	rulebooks.before.turn = {
		{
			name = "the player character exists",
			action = function (self)
				if self.player == nil then
					return "No player character has been set.", false
				end
			end
		},
		{
			-- This rule will make dark rooms "lit" if there is
			-- a light source in contact with open air.
			name = "and adjust the room light level",
			action = function (self, command)
				if self.room.dark == true then

					-- change the search options to include dark things
					local options = {
						includeClosed = false,
						includeDark = true
					}

					-- search for lit things, excluding the room itself.
					local searchfunc = function (n)
						return n.lit == true and n ~= self.room
					end

					-- query the search
					local lightsource = self:searchFirst (
						searchfunc, self.room, options)

					-- adjust the room light level
					if lightsource then
						-- TODO remove .lit when not used anymore
						self.room.lit = true
						self.room.is_lit = true
						self.room.is_dark = false
					else
						self.room.lit = false
						self.room.is_lit = false
						self.room.is_dark = true
					end
				end
			end
		}
	}

	rulebooks.after.turn = { }

end
