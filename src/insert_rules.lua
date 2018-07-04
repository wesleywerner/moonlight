--- The standard inserting things into other things rulebook.
-- @module insert_rules
return function (rulebooks)

	-- Note: the command direction will be "in" for containers
	-- when the input is "in" or "inside".
	rulebooks.before.insert = {
		{
			name = "check items exist",
			action = function (self, command)
				if not command.item1 then
					return string.format(self.template.missingFirstNoun, command.verb), false
				end
				if not command.item2 then
					return string.format(self.template.missingSecondNoun, command.verb, command.item1.name), false
				end
			end
		},
		{
			name = "into a non-container",
			--nouns = 2,
			action = function (self, command)
				if command.direction == "in" and type(command.item2.contains) ~= "table" then
					return string.format(self.template.notContainer, self:withArticle (command.item2)), false
				end
			end
		},
		{
			name = "onto a non-supporter",
			--nouns = 2,
			action = function (self, command)
				if command.direction == nil and type(command.item2.supports) ~= "table" then
					return string.format(self.template.notSupporter, self:withArticle (command.item2)), false
				end
			end
		}
	}

	rulebooks.on.insert = {
		{
			name = "a container",
			action = function (self, command)
				if command.direction == "in" then
					self:moveItemInto (command.item1, command.item2)
					return string.format(self.template.insertIn, command.item1.name, command.item2.name)
				end
			end
		},
		{
			name = "a supporter",
			action = function (self, command)
				if command.direction == nil then
					self:moveItemOnto (command.item1, command.item2)
					return string.format(self.template.insertOn, command.item1.name, command.item2.name)
				end
			end
		}
	}

end
