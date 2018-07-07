--- The standard dropping things rulebook.
-- @module drop_rules
return function (rulebooks)
	rulebooks.before.drop =	{
		{
			name = "unspecified nouns",
			action = function (self, command)
				if not command.item1 then
					if #command.nouns == 0 then
						return string.format(self.template.verbMissingNouns, command.verb), false
					else
						return string.format(self.template.dontSeeIt, command.nouns[1]), false
					end
				end
			end
		},
		{
			name = "thing not carried",
			action = function (self, command)
				if not self:isCarrying (command.item1) then
					return string.format(self.template.dontHaveIt, command.item1.name), false
				end
			end
		}
	}

	rulebooks.on.drop = {
		{
			name = "thing",
			action = function (self, command)
				self:moveItemInto (command.item1, self.room)
				return string.format(self.template.dropped, command.item1.name)
			end
		}
	}
end
