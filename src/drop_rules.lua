--- The standard dropping things rulebook.
-- @module drop_rules
return function (rulebooks)
	rulebooks.before.drop =	{
		{
			name = "unspecified nouns",
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
			name = "thing not carried",
			action = function (self, command)
				if not self:isCarrying (command.item1) then
					return string.format(self.responses.thing["not carried"], command.item1.name), false
				end
			end
		}
	}

	rulebooks.on.drop = {
		{
			name = "thing",
			action = function (self, command)
				self:moveIn (command.item1, self.room)
				return string.format(self.responses.drop["success"], command.item1.name)
			end
		}
	}
end
