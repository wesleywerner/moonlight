--- The standard turn rulebook.
-- @module turn_rules
return function (rulebooks)

	rulebooks.before.simulate = {
		{
			-- This rule will make dark rooms "lit" if there is
			-- a light source in contact with open air.
			name = "adjust the room light level",
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
					local lightsource = self:search_first (
						searchfunc, self.room, options)

					-- adjust the room light level
					if lightsource then
						self.room.is_lit = true
						self.room.is_dark = false
					else
						self.room.is_lit = false
						self.room.is_dark = true
					end
				else
					self.room.is_lit = true
					self.room.is_dark = false
				end
			end
		}
	}

end
