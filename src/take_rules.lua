--- The standard taking things rulebook.
-- @module take_rules
return function (rulebooks)

	rulebooks.before.take = {
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
			name = "in the dark",
			action = function (self, command)
				local darkroom = self.room.dark and not self.room.lit
				if darkroom and not command.item1 then
					return self.template.darkroomDescription .. self:listRoomExits(), false
				elseif darkroom and command.item1 then
					return self.template.tooDarkForThat, false
				end
			end
		},
		{
			name = "a person",
			action = function (self, command)
				if command.item1.person then
					return string.format(self.template.takePerson, command.item1.name), false
				end
			end
		},
		{
			name = "a fixed thing",
			action = function (self, command)
				if command.item1.fixed then
					return string.format(self.template.fixedInPlace, command.item1.name), false
				end
			end
		},
		{
			name = "something already carried",
			action = function (self, command)
				if self:isCarrying (command.item1) then
					return self.template.alreadyHaveIt, false
				end
			end
		}
	}

	rulebooks.on.take = {
		{
			name = "thing",
			action = function (self, command)
				self:moveItemInto (command.item1, self.player)
				return string.format(self.template.taken, command.item1.name)
			end
		}
	}

end
