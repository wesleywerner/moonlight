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
					return string.format(self.template.thing["not carried"], command.nouns[1]), false
				end
				if not command.item2 then
					return string.format(self.template.unknown["thing"], command.nouns[2]), false
				end
			end
		},
		{
			name = "player is carrying the thing",
			action = function (self, command)
				if not self:isCarrying (command.item1) then
					return string.format(self.template.thing["not carried"], command.item1.name), false
				end
			end
		},
		{
			name = "into a non-container",
			action = function (self, command)
				if command.direction == "in" and type(command.item2.contains) ~= "table" then
					return string.format(self.template.insert["not container"], self:withArticle (command.item2)), false
				end
			end
		},
		{
			name = "onto a non-supporter",
			action = function (self, command)
				if command.direction == nil and type(command.item2.supports) ~= "table" then
					return string.format(self.template.insert["not supporter"], self:withArticle (command.item2)), false
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
					return string.format(self.template.insert["in"], command.item1.name, command.item2.name)
				end
			end
		},
		{
			name = "a supporter",
			action = function (self, command)
				if command.direction == nil then
					self:moveItemOnto (command.item1, command.item2)
					return string.format(self.template.insert["on"], command.item1.name, command.item2.name)
				end
			end
		}
	}

end
