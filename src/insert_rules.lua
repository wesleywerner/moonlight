--- The standard inserting things into other things rulebook.
-- @module insert_rules
return function (rulebooks)

	-- Note: the command direction will be "in" for containers
	-- when the input is "in" or "inside".
	rulebooks.before.insert = {
		{
			name = "the nouns exist",
			action = function (self, command)
				if not command.item1 then
					return string.format(self.responses.thing["not carried"], command.nouns[1]), false
				end
				if not command.item2 then
					return string.format(self.responses.unknown["thing"], command.nouns[2]), false
				end
			end
		},
		{
			name = "the player is carrying the first noun",
			action = function (self, command)
				if not self:isCarrying (command.item1) then
					return string.format(self.responses.thing["not carried"], command.item1.name), false
				end
			end
		},
		{
			name = "the second noun can contain things",
			action = function (self, command)
				if command.direction == "in" and type(command.item2.contains) ~= "table" then
					return string.format(self.responses.insert["not container"], self:withArticle (command.item2)), false
				end
			end
		},
		{
			name = "the second noun can support things",
			action = function (self, command)
				if command.direction == nil and type(command.item2.supports) ~= "table" then
					return string.format(self.responses.insert["not supporter"], self:withArticle (command.item2)), false
				end
			end
		},
		{
			name = "the second noun is a closed container",
			action = function (self, command)
				if command.item2.closed == true then
					return string.format(self.responses.insert["into closed"], command.item2.name), false
				end
			end
		}
	}

	rulebooks.on.insert = {
		{
			name = "move the noun into the container",
			action = function (self, command)
				if command.direction == "in" then
					self:moveIn (command.item1, command.item2)
					return string.format(self.responses.insert["in"], command.item1.name, command.item2.name)
				end
			end
		},
		{
			name = "move the noun onto the supporter",
			action = function (self, command)
				if command.direction == nil then
					self:moveOn (command.item1, command.item2)
					return string.format(self.responses.insert["on"], command.item1.name, command.item2.name)
				end
			end
		}
	}

end
