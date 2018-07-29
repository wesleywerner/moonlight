--- The standard taking things rulebook.
-- @module take_rules
return function (rulebooks)

	rulebooks.before.take = {
		{
			name = "unspecified nouns",
			action = function (self, command)
				if not command.item1 then
					if #command.nouns == 0 then
						return string.format(self.template.missing["noun"], command.verb), false
					else
						return string.format(self.template.unknown["thing"], command.nouns[1]), false
					end
				end
			end
		},
		{
			name = "in the dark",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom then
					return self.template.take["in the dark"], false
				end
			end
		},
		{
			name = "a person",
			action = function (self, command)
				if command.item1.person then
					return string.format(self.template.take["person"], command.item1.name), false
				end
			end
		},
		{
			name = "a fixed thing",
			action = function (self, command)
				if command.item1.fixed then
					return string.format(self.template.thing["fixed"], command.item1.name), false
				end
			end
		},
		{
			name = "something already carried",
			action = function (self, command)
				if self:isCarrying (command.item1) then
					return self.template.take["when carried"], false
				end
			end
		}
	}

	rulebooks.on.take = {
		{
			name = "thing",
			action = function (self, command)
				self:moveIn (command.item1, self.player)
				return string.format(self.template.take["success"], command.item1.name)
			end
		}
	}

end
