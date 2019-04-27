--- The standard taking things rulebook.
-- @module take_rules
return function (rulebooks)

	rulebooks.before.take = {
		{
			name = "the noun exists",
			action = function (self, command)
				if not command.item1 then
					if #command.nouns == 0 then
						return string.format(self.responses.missing["noun"], command.verb), false
					else
						return string.format(self.responses.unknown["thing"], command.nouns[1]), false
					end
				end
			end
		},
		{
			-- TODO Move darkness CHECK to the turn rulebooks
			name = "in the dark",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom then
					return self.responses.take["in the dark"], false
				end
			end
		},
		{
			name = "not taking a person",
			action = function (self, command)
				if command.item1.person then
					return string.format(self.responses.take["person"], command.item1.name), false
				end
			end
		},
		{
			name = "the noun is not fixed in place",
			action = function (self, command)
				if command.item1.fixed then
					-- the fixed value can be custom text
					if type(command.item1.fixed) == "string" then
						return command.item1.fixed, false
					else
						return string.format(self.responses.thing["fixed"], command.item1.name), false
					end
				end
			end
		},
		{
			name = "the noun is not already carried",
			action = function (self, command)
				if self:isCarrying (command.item1) then
					return self.responses.take["when carried"], false
				end
			end
		}
	}

	rulebooks.on.take = {
		{
			name = "take the noun",
			action = function (self, command)
				self:moveIn (command.item1, self.player)
				--return string.format(self.responses.take["success"], command.item1.name)
			end
		}
	}

	rulebooks.after.take = {
		{
			name = "report",
			action = function (self, command)
				return string.format(self.responses.take["success"], command.item1.name)
			end
		}
	}

end
